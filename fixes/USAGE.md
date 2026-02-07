# Cara pakai patch (langsung siap pakai)

## Opsi A (disarankan): tanpa ubah function utama
Tambahkan script ini **setelah** script utama di `tas.html`:

```html
<script src="./fixes/dramacina-fix.js"></script>
```

Patch akan otomatis:
- menambahkan validasi ID pada `openDrama`
- meng-override `cardHTML` supaya aman untuk ID string
- mencegah card tanpa ID memanggil `openDrama(undefined)`

## Opsi B: copy-paste manual
Kalau tidak mau pakai file eksternal, copy isi helper/function dari `dramacina-fix.js` ke akhir `<script>` utama.

## Checklist test
1. Buka halaman utama.
2. Klik card yang sebelumnya error.
3. Pastikan:
   - card dengan ID valid membuka modal
   - card tanpa ID tidak crash (hanya toast)
   - tidak ada error `openDrama: invalid ID` untuk card valid
