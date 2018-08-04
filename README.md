# Pelatihan-Altimetri
Pelatihan altimetri dilaksanakan pada tanggal 10-20 Juni 2018. Pelatihan ini memfokuskan kepada pengolahan data altimetri yang diperoleh dari server rads.

File-file yang disediakan disini ialah:
1. **reformat.m** : mengubah rads ke dalam struct file matlab untuk memudahkan pengolahan
2. **collinear_analysis.m** : melakukan collinear analysis pada semua satelit yang ingin diolah
    *  **Catatan**  : pilih semua satelit dari vendor yang sama dan pada posisi ascending atau descending saja
    *  **Subrutin** : collinearf.m
3. **plot_ssh_UI.m** : menampilkan nilai SSH pada footprint & track yang dipilih oleh user secara interaktif. Grafik disimpan secara otomatis
4. **tidegen.m** : melakukan tidal estimate untuk mendapatkan amplitudo dan fase tiap konstituen pasang surut di setiap footprint
    *  **Catatan**  : 
    *  **Subrutin** : tidal_estimate.m, lsa_tide.m, find_outliers_Thompson.m 
5. **Remove_Empty_Pass.m** : menghilangkan data NaN dan data kosong ([] ) di dalam pass dan footprint
    *  **Catatan**  : 
    *  **Subrutin** : rempass.m, remfoot.m.
6. **plot_lsa_tEstimate.m** : menampilkan grafik time series nilai SSH observasi dan prediksi, error SSH, dan tidal correlation tiap footprint pada track yang dipilih secara interaktif oleh user
7. **XoverPoint.m** : digunakan untuk mengecek nilai amplitudo dan fase tiap konstituen pada mode ascending dan descending
    *  **Catatan**  : tentukan konstituen yang akan dicari titik cross over.
    *  **Subrutin** : rempass.m, remfoot.m.  
    *  **Output**   : grafik titik cross over, file .mat tiap konstituen
8.  **Plot_Residu_Xover.m** : Plot ini digunakan untuk melihat error nilai amplitudo dan fase pada semua titik cross over
9. **landmaskgebco.m** : digunakan untuk mengekstrak titik satelit altimetry yang berada di perairan berdasarkan data GEBCO sebagai batas darat laut.
    *  **Catatan**  : tentukan file yang akan diekstrak (Estimate atau xover), tentukan nilai ketinggian/kedalaman sebagai batas darat-laut. data GEBCO diekstrak dan diletakkan di dalam folder yang sama dengan maskgebco.m
    *  **Subrutin** : maskgebco.m.  
    *  **Output**   : figure titik hasil filter GEBCO, mat file titik yang sudah difilter darat.
10.  **validasiFES.m** : digunakan untuk memvalidasi konstituen data altimetri dengan data FES2014.
    *  **Subrutin** : validasi.m.  
    *  **Output**   : grafik sebaran amplitude dan fase tiap konstituen data altimetri, FES2014, dan residu; file .mat berisikan data titik altimetri, FES2014, dan residu tiap konstituennya; validation report
11.  **loopsave.m** : digunakan untuk mengekspor data amplitude, phase, dan standar deviasi mode _Ascending_ dan _Descending_ ke        dalam satu teks file.
    *  **Subrutin** : rempass.m, findcons.m, savedata.m.  
    *  **Output**   : file teks amplitude, phase, dan standar deviasi tiap konstituen pasut
12.  **savexover.m** : digunakan untuk mengekspor nilai residu amplitude, phase, dan diff resultan vektor tiap konstituen pasut di titik cross over
    *  **Output**   : file teks residu amplitude, residu phase, dan diff resultan vektor tiap konstituen pasut
