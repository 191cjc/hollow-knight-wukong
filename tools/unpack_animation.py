"""Unpack the game's public AMF3 animation bundles without running game code."""
from pathlib import Path
import json
import struct
import zlib


class AMF3:
    def __init__(self, data):
        self.data, self.pos = data, 0
        self.strings, self.objects, self.traits = [], [], []

    def take(self, size):
        result = self.data[self.pos:self.pos + size]
        if len(result) != size:
            raise ValueError("Truncated AMF3 value")
        self.pos += size
        return result

    def u29(self):
        result = 0
        for index in range(4):
            byte = self.take(1)[0]
            if index == 3:
                return (result << 8) | byte
            result = (result << 7) | (byte & 127)
            if byte < 128:
                return result
        raise ValueError("Invalid AMF3 integer")

    def string(self):
        header = self.u29()
        if not header & 1:
            return self.strings[header >> 1]
        result = self.take(header >> 1).decode("utf-8")
        if result:
            self.strings.append(result)
        return result

    def read(self):
        marker = self.take(1)[0]
        if marker in (0, 1):
            return None
        if marker in (2, 3):
            return marker == 3
        if marker == 4:
            value = self.u29()
            return value - (1 << 29) if value & (1 << 28) else value
        if marker == 5:
            return struct.unpack(">d", self.take(8))[0]
        if marker == 6:
            return self.string()
        if marker == 12:
            header = self.u29()
            if not header & 1:
                return self.objects[header >> 1]
            result = self.take(header >> 1)
            self.objects.append(result)
            return result
        if marker == 10:
            header = self.u29()
            if not header & 1:
                return self.objects[header >> 1]
            if header & 2:
                if header & 4:
                    raise ValueError("Externalizable AMF3 object is unsupported")
                class_name = self.string()
                names = [self.string() for _ in range(header >> 4)]
                trait = (class_name, bool(header & 8), names)
                self.traits.append(trait)
            else:
                trait = self.traits[header >> 2]
            class_name, dynamic, names = trait
            result = {}
            self.objects.append(result)
            for name in names:
                result[name] = self.read()
            if dynamic:
                while True:
                    name = self.string()
                    if not name:
                        break
                    result[name] = self.read()
            return result
        raise ValueError(f"Unsupported AMF3 marker {marker} at {self.pos - 1}")


def unpack(source, output):
    raw = source.read_bytes()
    reader = AMF3(raw)
    metadata = reader.read()
    result = []
    for _ in range(metadata["fn"]):
        # Each ByteArray.readObject() stream has its own reference tables.
        reader.strings, reader.objects, reader.traits = [], [], []
        compressed = reader.read()
        embedded = AMF3(zlib.decompress(compressed, -15))
        item = embedded.read()
        if embedded.pos != len(embedded.data):
            raise ValueError("Trailing data in animation entry")
        name = item["name"]
        if Path(name).name != name or "\\" in name:
            raise ValueError("Unexpected animation filename")
        data = zlib.decompress(item["data"])
        if name.endswith(".json"):
            json.loads(data)
        if name.endswith(".png") and not data.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError("Invalid PNG signature")
        output.mkdir(parents=True, exist_ok=True)
        (output / name).write_bytes(data)
        result.append({"name": name, "size": len(data)})
    if reader.pos != len(raw):
        raise ValueError("Trailing data in animation bundle")
    return result


if __name__ == "__main__":
    import sys
    source_root = Path(sys.argv[1])
    destination = Path(sys.argv[2])
    for source in sorted(source_root.rglob("*.swf")):
        if source.read_bytes()[:3] in (b"FWS", b"CWS", b"ZWS"):
            continue
        output = destination / source.relative_to(source_root).with_suffix("")
        print(json.dumps({"source": str(source), "files": unpack(source, output)}, ensure_ascii=False))
