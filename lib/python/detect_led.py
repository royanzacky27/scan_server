import cv2
import numpy as np

def classify_color(hue, sat, val):
    if val < 150:
        return '❔ Gelap/Noise', (128, 128, 128)

    if 35 < hue < 85:
        return '🟢 Normal (Hijau)', (0, 255, 0)
    elif 15 < hue < 35:
        return '🟡 Warning (Amber)', (0, 255, 255)
    elif hue < 10 or hue > 170:
        return '🔴 Critical (Merah)', (0, 0, 255)
    else:
        return '⚪ Tidak Terdeteksi', (255, 255, 255)

# Inisialisasi kamera
cap = cv2.VideoCapture(0)  # Ganti jadi 1 kalau pakai USB webcam

print("🔍 Mulai scanning LED... Tekan 'q' untuk keluar.")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.resize(frame, (640, 480))
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

    # Cari titik terang (LED menyala)
    mask_bright = cv2.inRange(hsv, (0, 0, 200), (180, 60, 255))
    contours, _ = cv2.findContours(mask_bright, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area > 30:  # abaikan noise kecil
            x, y, w, h = cv2.boundingRect(cnt)
            roi = hsv[y:y+h, x:x+w]

            avg_hue = np.mean(roi[:, :, 0])
            avg_sat = np.mean(roi[:, :, 1])
            avg_val = np.mean(roi[:, :, 2])

            status, color = classify_color(avg_hue, avg_sat, avg_val)

            # Gambar kotak dan label status
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            cv2.putText(frame, status, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    # Tampilkan frame
    cv2.imshow("Inti Scanning - LED Detection", frame)

    # Stop jika tekan 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Bersih-bersih
cap.release()
cv2.destroyAllWindows()
print("🛑 Scan dihentikan.")