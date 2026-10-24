import piexif
from PIL import Image

img = Image.new("RGB", (640, 480), color=(120, 180, 220))

zeroth = {piexif.ImageIFD.Make: b"OneTouchSpike", piexif.ImageIFD.Orientation: 6}
exif_ifd = {
    piexif.ExifIFD.DateTimeOriginal: b"2026:07:02 12:34:56",
}
gps_ifd = {
    piexif.GPSIFD.GPSLatitudeRef: b"N",
    piexif.GPSIFD.GPSLatitude: ((37, 1), (33, 1), (0, 1)),
    piexif.GPSIFD.GPSLongitudeRef: b"E",
    piexif.GPSIFD.GPSLongitude: ((127, 1), (0, 1), (0, 1)),
}
exif_dict = {"0th": zeroth, "Exif": exif_ifd, "GPS": gps_ifd}
exif_bytes = piexif.dump(exif_dict)
img.save("test_source.jpg", "jpeg", exif=exif_bytes)
print("wrote test_source.jpg with EXIF: orientation=6, DateTimeOriginal=2026:07:02 12:34:56, GPS=37.55N,127.0E")
