"""Read-only PE metadata and selected nested IL evidence; no Unity execution.

The shared Cecil inspector cannot visit nested iterator types. This task-local
reader leaves that tool untouched and adds no project/toolchain dependencies.
"""
from pathlib import Path
import struct
import re

SOURCE = Path('.tools/hollow-knight-api-v77/Assembly-CSharp.dll')
OUTPUT = Path(__file__).parent
b = SOURCE.read_bytes()
u16 = lambda p: struct.unpack_from('<H', b, p)[0]
u32 = lambda p: struct.unpack_from('<I', b, p)[0]
pe = u32(0x3c)
opt = pe + 24
sh = opt + u16(pe + 20)
regions = [(u32(sh + 40*n + 12), max(u32(sh + 40*n + 8), u32(sh + 40*n + 16)),
            u32(sh + 40*n + 20)) for n in range(u16(pe + 6))]

def offset(rva):
    for start, size, raw in regions:
        if start <= rva < start + size:
            return raw + rva - start
    raise ValueError(rva)

cli = offset(u32(opt + (96 if u16(opt) == 0x10b else 112) + 14*8))
md = offset(u32(cli + 8))
p = (md + 16 + u32(md + 12) + 3) & ~3
count = u16(p + 2)
p += 4
streams = {}
for _ in range(count):
    end = b.index(0, p + 8)
    streams[b[p + 8:end].decode()] = (md + u32(p), u32(p + 4))
    p = (end + 4) & ~3
t = streams.get('#~', streams.get('#-'))[0]
hs = b[t + 6]
valid = struct.unpack_from('<Q', b, t + 8)[0]
p = t + 24
rows = {}
for n in range(64):
    if valid & (1 << n):
        rows[n] = u32(p)
        p += 4
ss, gs, bs = (4 if hs & bit else 2 for bit in (1, 2, 4))
idx = lambda n: 4 if rows.get(n, 0) >= 65536 else 2
coded = lambda ns, bits: 4 if max(rows.get(n, 0) for n in ns) >= (1 << (16-bits)) else 2
rs = coded((0, 26, 35, 1), 2)
tor = coded((2, 1, 27), 2)
mrp = coded((2, 1, 26, 6, 27), 3)
sizes = {0: 2+ss+3*gs, 1: rs+2*ss, 2: 4+2*ss+tor+idx(4)+idx(6),
         3: idx(4), 4: 2+ss+bs, 5: idx(6), 6: 8+ss+bs+idx(8),
         7: idx(8), 8: 4+ss, 9: idx(2)+tor, 10: mrp+ss+bs}
starts = {}
for n in range(11):
    starts[n] = p
    p += sizes[n] * rows.get(n, 0)
read = lambda p, n: int.from_bytes(b[p:p+n], 'little')

def st(i):
    p = streams['#Strings'][0] + i
    return b[p:b.index(0, p)].decode()

def name_at(table, row, pad=0):
    return st(read(starts[table] + sizes[table]*(row-1) + pad, ss))

types, owners, fieldowners, inventory = {}, {}, {}, []
for n in range(1, rows[2]+1):
    p = starts[2] + sizes[2]*(n-1)
    name, ns = st(read(p+4, ss)), st(read(p+4+ss, ss))
    types[n] = (ns+'.' if ns else '') + name
for n in range(1, rows[2]+1):
    p = starts[2] + sizes[2]*(n-1)
    f = read(p+4+2*ss+tor, idx(4))
    m = read(p+4+2*ss+tor+idx(4), idx(6))
    if n < rows[2]:
        nxt = p+sizes[2]
        fn = read(nxt+4+2*ss+tor, idx(4))
        mn = read(nxt+4+2*ss+tor+idx(4), idx(6))
    else:
        fn, mn = rows[4]+1, rows[6]+1
    for x in range(f, fn):
        fieldowners[x] = types[n]
    for x in range(m, mn):
        owners[x] = types[n]
    if '.' not in types[n]:
        inventory.append(types[n]+': '+', '.join(name_at(6, x, 8) for x in range(m, mn)))

def token(tok):
    table, i = tok >> 24, tok & 0xffffff
    if table == 0x70:
        p = streams['#US'][0]+i
        first = b[p]
        if first < 128:
            n, p = first, p+1
        elif first < 192:
            n, p = ((first & 63) << 8) | b[p+1], p+2
        else:
            n, p = ((first & 31) << 24) | (b[p+1] << 16) | (b[p+2] << 8) | b[p+3], p+4
        return repr(b[p:p+n-1].decode('utf-16-le'))
    if table == 2:
        return types[i]
    if table == 1:
        p = starts[1]+sizes[1]*(i-1)
        name, ns = st(read(p+rs, ss)), st(read(p+rs+ss, ss))
        return (ns+'.' if ns else '')+name
    if table == 4:
        return fieldowners[i]+'::'+name_at(4, i, 2)
    if table == 6:
        return owners[i]+'::'+name_at(6, i, 8)
    if table == 10:
        p = starts[10]+sizes[10]*(i-1)
        parent = read(p, mrp)
        pt, rid = (2, 1, 26, 6, 27)[parent & 7], parent >> 3
        parentname = token((pt << 24) | rid) if pt in (1, 2, 6) else f'parent_{pt}_{rid}'
        return parentname+'::'+st(read(p+mrp, ss))
    return f'token_0x{tok:08x}'

base = {0x00: ('nop', ''), 0x01: ('break', ''), 0x0e: ('ldarg.s', 'B'),
        0x0f: ('ldarga.s', 'B'), 0x10: ('starg.s', 'B'), 0x11: ('ldloc.s', 'B'),
        0x12: ('ldloca.s', 'B'), 0x13: ('stloc.s', 'B'), 0x14: ('ldnull', ''),
        0x1f: ('ldc.i4.s', 'b'), 0x20: ('ldc.i4', 'i'), 0x21: ('ldc.i8', 'q'),
        0x22: ('ldc.r4', 'f'), 0x23: ('ldc.r8', 'd'), 0x25: ('dup', ''),
        0x26: ('pop', ''), 0x27: ('jmp', 'T'), 0x28: ('call', 'T'),
        0x29: ('calli', 'T'), 0x2a: ('ret', ''), 0x45: ('switch', 'S'),
        0x6f: ('callvirt', 'T'), 0x70: ('cpobj', 'T'), 0x71: ('ldobj', 'T'),
        0x72: ('ldstr', 'T'), 0x73: ('newobj', 'T'), 0x74: ('castclass', 'T'),
        0x75: ('isinst', 'T'), 0x79: ('unbox', 'T'), 0x7a: ('throw', ''),
        0x7b: ('ldfld', 'T'), 0x7c: ('ldflda', 'T'), 0x7d: ('stfld', 'T'),
        0x7e: ('ldsfld', 'T'), 0x7f: ('ldsflda', 'T'), 0x80: ('stsfld', 'T'),
        0x81: ('stobj', 'T'), 0x8c: ('box', 'T'), 0x8d: ('newarr', 'T'),
        0x8e: ('ldlen', ''), 0x8f: ('ldelema', 'T'), 0xa3: ('ldelem', 'T'),
        0xa4: ('stelem', 'T'), 0xa5: ('unbox.any', 'T'),
        0xdc: ('endfinally', ''), 0xdd: ('leave', 'I'), 0xde: ('leave.s', 's')}
for code, name in enumerate(('ldarg.0', 'ldarg.1', 'ldarg.2', 'ldarg.3', 'ldloc.0',
                             'ldloc.1', 'ldloc.2', 'ldloc.3', 'stloc.0', 'stloc.1',
                             'stloc.2', 'stloc.3'), 2):
    base[code] = name, ''
for code, value in enumerate(range(-1, 9), 0x15):
    base[code] = f'ldc.i4.{value}', ''
branches = ('br', 'brfalse', 'brtrue', 'beq', 'bge', 'bgt', 'ble', 'blt', 'bne.un',
            'bge.un', 'bgt.un', 'ble.un', 'blt.un')
for k, name in enumerate(branches):
    base[0x2b+k], base[0x38+k] = (name+'.s', 's'), (name, 'I')
for start, names in (
    (0x46, ('ldind.i1', 'ldind.u1', 'ldind.i2', 'ldind.u2', 'ldind.i4', 'ldind.u4',
            'ldind.i8', 'ldind.i', 'ldind.r4', 'ldind.r8', 'ldind.ref', 'stind.ref',
            'stind.i1', 'stind.i2', 'stind.i4', 'stind.i8', 'stind.r4', 'stind.r8')),
    (0x58, ('add', 'sub', 'mul', 'div', 'div.un', 'rem', 'rem.un', 'and', 'or', 'xor',
            'shl', 'shr', 'shr.un', 'neg', 'not')),
    (0x67, ('conv.i1', 'conv.i2', 'conv.i4', 'conv.i8', 'conv.r4', 'conv.r8', 'conv.u4', 'conv.u8')),
    (0x90, ('ldelem.i1', 'ldelem.u1', 'ldelem.i2', 'ldelem.u2', 'ldelem.i4', 'ldelem.u4',
            'ldelem.i8', 'ldelem.i', 'ldelem.r4', 'ldelem.r8', 'ldelem.ref')),
    (0x9b, ('stelem.i', 'stelem.i1', 'stelem.i2', 'stelem.i4', 'stelem.i8', 'stelem.r4',
            'stelem.r8', 'stelem.ref'))):
    for k, name in enumerate(names, start):
        base[k] = name, ''
extra = {1: ('ceq', ''), 2: ('cgt', ''), 3: ('cgt.un', ''), 4: ('clt', ''),
         5: ('clt.un', ''), 6: ('ldftn', 'T'), 7: ('ldvirtftn', 'T'),
         21: ('initobj', 'T'), 22: ('constrained.', 'T'), 26: ('rethrow', '')}
selected = {'<DoStun>d__23', '<Walk>d__17', '<Walk>d__11', '<Turn>d__12', '<PlayAnimWait>d__5'}
out = [f'Source: {SOURCE}; read-only Python PE/ECMA-335 decoding for nested iterator bodies.',
       'No shared inspector source or binary was changed. Member signatures are abbreviated.']
for row in range(1, rows[6]+1):
    owner, name = owners[row], name_at(6, row, 8)
    if owner not in selected or name != 'MoveNext':
        continue
    rva = u32(starts[6]+sizes[6]*(row-1))
    if not rva:
        continue
    p = offset(rva)
    if b[p] & 3 == 2:
        size, p = b[p] >> 2, p+1
    else:
        size, p = u32(p+4), p+(u16(p) >> 12)*4
    code, cur = b[p:p+size], 0
    out.append(f'METHOD {owner}::{name} RVA=0x{rva:08x} bytes={size}')
    while cur < len(code):
        start, op = cur, code[cur]
        cur += 1
        table = base
        if op == 0xfe:
            op = code[cur]
            cur += 1
            table = extra
        if op not in table:
            raise ValueError(f'unsupported opcode {op:x} at {owner} {start:x}')
        opname, fmt = table[op]
        operand = ''
        if fmt == 'S':
            cnt = struct.unpack_from('<I', code, cur)[0]
            cur += 4
            end = cur+cnt*4
            operand = ','.join(f'IL_{end+struct.unpack_from("<i", code, cur+4*j)[0]:04x}'
                               for j in range(cnt))
            cur = end
        elif fmt:
            f = {'T': 'I', 's': 'b', 'I': 'i'}.get(fmt, fmt)
            value = struct.unpack_from('<'+f, code, cur)[0]
            cur += struct.calcsize(f)
            operand = token(value) if fmt == 'T' else f'IL_{cur+value:04x}' if fmt in ('s', 'I') else str(value)
        out.append(f'IL_{start:04x}: {opname} {operand}'.rstrip())
(OUTPUT/'native-controller-nested-il.txt').write_text('\n'.join(out)+'\n')
(OUTPUT/'native-controller-method-catalog.txt').write_text(
    f'Source: {SOURCE}; global-namespace TypeDef method names.\n'+'\n'.join(inventory)+'\n')
entry_names = []
for row in range(1, rows[6]+1):
    name = name_at(6, row, 8)
    if re.search(r'hurt|stun|(?:^|_)Hit|TakeDamage|RecieveHit|CancelAttack|StopAttack', name, re.I):
        entry_names.append(owners[row]+'::'+name)
(OUTPUT/'native-controller-hurt-methods.txt').write_text(
    f'Source: {SOURCE}; all namespaces; name search only, not support evidence.\n'
    +'\n'.join(entry_names)+'\n')
print(f'Wrote {len(out)} IL lines and {len(inventory)} type method inventories')
