# Pelatihan-Altimetri
Pelatihan altimetri dilaksanakan pada tanggal 10-20 Juni 2018. Pelatihan ini memfokuskan kepada pengolahan data altimetri yang diperoleh dari server rads.

File-file yang disediakan disini ialah:
1. **reformat.m** : mengubah rads ke dalam struct file matlab untuk memudahkan pengolahan
2. **collinear_analysis.m** : melakukan collinear analysis pada semua satelit yang ingin diolah
    *  **Catatan** : pilih semua satelit dari vendor yang sama dan pada posisi ascending atau descending saja
    *  **Subrutin** : collinearf.m
3. **plot_ssh_UI.m** : menampilkan nilai SSH pada footprint & track yang dipilih oleh user secara interaktif. Grafik disimpan secara otomatis
4. **tidegen.m** : melakukan tidal estimate untuk mendapatkan amplitudo dan fase tiap konstituen pasang surut di setiap footprint
    *  **Catatan** : 
    *  **Subrutin** : tidal_estimate.m, lsa_tide.m, find_outliers_Thompson.m .
5. **Remove_Empty_Pass.m** : menghilangkan data NaN dan data kosong ([] ) di dalam pass dan footprint
    *  **Catatan** : 
    *  **Subrutin** : rempass.m, remfoot.m.
6. **plot_lsa_tEstimate.m** : menampilkan grafik time series nilai SSH observasi dan prediksi, error SSH, dan tidal correlation tiap footprint pada track yang dipilih secara interaktif oleh user
