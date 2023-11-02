;Pro get_Fractional_Composition_of_MHD_modes_MainProgram
mag_suite_str = 'fld'
mag_level_str = 'l2'
mag_payload_str = 'mag'
mag_coord_str = 'rtn'
mag_cadence_str = '';'_1min'; '', '_1min'
spc_suite_str = 'swp'
spc_level_str = 'l3i';l2i,;l3i
spc_pre_level_str = StrMid(spc_level_str,0,2)
spc_payload_str = 'spc'
;;--
ymd_str = '20200128'
year_str = StrMid(ymd_str,0,4)
mon_str  = StrMid(ymd_str,4,2)
day_str  = StrMid(ymd_str,6,2)
;;--
is_timerange_automatic_for_cal = 1
is_timerange_automatic_for_plot = 0
If is_timerange_automatic_for_cal eq 0 Then Begin
  If StrCmp(ymd_str, '20181031') eq 1 Then Begin
    hms_beg_cal_str = '02:30:13'
    hms_end_cal_str = '02:36:03'
  Endif
Endif
If is_timerange_automatic_for_plot eq 0 Then Begin
  If StrCmp(ymd_str, '20181106') eq 1 Then Begin
    hms_beg_plot_str = '01:50:00'
    hms_end_plot_str = '02:40:00'
    hms_beg_plot_str = '02:30:00'
    hms_end_plot_str = '03:20:00'
  Endif
  If StrCmp(ymd_str, '20200128') eq 1 Then Begin
    hms_beg_plot_str = '12:00:00'
    hms_end_plot_str = '15:00:00'
  Endif
Endif
;;--
PSP_Data_Dir = '/Volumes/Elements/PSP_Data_Analysis/savData/'+$
  year_str +'-'+ mon_str +'-'+ day_str +'/'
PSP_Figure_Dir = '/Users/psr/Documents/research/PSP_Data_Analysis/Figures/'+$
  year_str +'-'+ mon_str +'-'+ day_str +'/'
is_use_optimazation_spc = 1
spc_v_str = is_use_optimazation_spc eq 1 ? '(optimized)':''
is_execute_low_filter = 1
;goto,Step7
Step1:
;===========================
;Step1:
dir_data = PSP_Data_Dir
;;--
TimeRange_Restore_Str = '(time=??????-??????)'
file_restore  = 'Bxyz_RTN_arr'+$
  '(psp_'+mag_suite_str+'_'+mag_level_str+'_'+mag_payload_str+'_'+mag_coord_str+mag_cadence_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_Restore_Str+$
  '.sav'
file_array  = File_Search(dir_data+file_restore, count=num_files)
For i_file=0,num_files-1 Do Begin
  Print, 'i_file, file: ', i_file, ': ', file_array[i_file]
EndFor
i_select  = 0
Read, 'i_select: ', i_select
file_restore  = file_array[i_select]
file_restore  = StrMid(file_restore, StrLen(dir_data), StrLen(file_restore)-StrLen(dir_data))
;;;---
Restore, dir_data+file_restore, /verbose
;data_descrip  = 'got from "Read_PSP_MAG_L2_CDF.pro"'
;Save, FileName=dir_save+file_save, $
;  data_descrip, $
;  TimeRange_str, $
;  JulDay_vect_save, Bx_RTN_vect_save, By_RTN_vect_save, Bz_RTN_vect_save, $
;  JulDay_vect_interp, Bx_RTN_vect_interp, By_RTN_vect_interp, Bz_RTN_vect_interp, $
;  sub_beg_BadBins_vect, sub_end_BadBins_vect, $
;  num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
JulDay_vect_mag = JulDay_vect_interp
Bx_RTN_vect = Bx_RTN_vect_interp
By_RTN_vect = By_RTN_vect_interp
Bz_RTN_vect = Bz_RTN_vect_interp

;;--
TimeRange_Restore_Str = '(time=??????-??????)'
file_restore  = 'Np_Wp_Vp_RTN_arr'+spc_v_str+$
  '(psp_'+spc_suite_str+'_'+spc_payload_str+'_'+spc_level_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_Restore_Str+$
  '.sav'
file_array  = File_Search(dir_data+file_restore, count=num_files)
For i_file=0,num_files-1 Do Begin
  Print, 'i_file, file: ', i_file, ': ', file_array[i_file]
EndFor
i_select  = 0
Read, 'i_select: ', i_select
file_restore  = file_array[i_select]
file_restore  = StrMid(file_restore, StrLen(dir_data), StrLen(file_restore)-StrLen(dir_data))
;;;---
Restore, dir_data+file_restore, /verbose
;data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
;Save, FileName=dir_save+file_save, $
;  data_descrip, $
;  TimeRange_str, $
;  JulDay_vect_save, Np_RTN_vect_save, Wp_RTN_vect_save, $
;  Vpx_RTN_vect_save, Vpy_RTN_vect_save, Vpz_RTN_vect_save, $
;  sub_beg_BadBins_vect, sub_end_BadBins_vect, $
;  num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
JulDay_vect_spc = JulDay_vect_save
Np_RTN_vect = Np_RTN_vect_save
Wp_RTN_vect = Wp_RTN_vect_save
Vpx_RTN_vect = Vpx_RTN_vect_save
Vpy_RTN_vect = Vpy_RTN_vect_save
Vpz_RTN_vect = Vpz_RTN_vect_save


Step2:
;===========================
;Step2:
;;--use default time range or reset another small time interval to calculate wavelet and local background
;;--smaller interval is suggested for large size of burst data set (e.g., > 100 MB for x&E&B...sav and J&divB...sav)
Print, 'use default time range or reset another small time interval to calculate wavelet and local background'
Print, 'smaller interval is suggested for large size of burst data set (e.g., > 100 MB for x&E&B...sav and J&divB...sav)'
Print, 'is_timerange_automatic_for_cal (0 for defined by user, 1 for automatically inherited from original data): '
Print, is_timerange_automatic_for_cal
is_continue = ' '
Read, 'is_continue: ', is_continue
If is_timerange_automatic_for_cal eq 0 Then Begin
  hh_beg_cal_str = StrMid(hms_beg_cal_str,0,2) & mm_beg_cal_str = StrMid(hms_beg_cal_str,3,2) & ss_beg_cal_str = StrMid(hms_beg_cal_str,6,2)
  hh_end_cal_str = StrMid(hms_end_cal_str,0,2) & mm_end_cal_str = StrMid(hms_end_cal_str,3,2) & ss_end_cal_str = StrMid(hms_end_cal_str,6,2)
  year_beg_cal=Float(year_str) & mon_beg_cal=Float(mon_str) & day_beg_cal=Float(day_str)
  year_end_cal=Float(year_str) & mon_end_cal=Float(mon_str) & day_end_cal=Float(day_str)
  hour_beg_cal=Float(hh_beg_cal_str) & min_beg_cal=Float(mm_beg_cal_str) & sec_beg_cal=Float(ss_beg_cal_str)
  hour_end_cal=Float(hh_end_cal_str) & min_end_cal=Float(mm_end_cal_str) & sec_end_cal=Float(ss_end_cal_str)
  JulDay_beg_cal = JulDay(mon_beg_cal,day_beg_cal,year_beg_cal, hour_beg_cal,min_beg_cal,sec_beg_cal)
  JulDay_end_cal = JulDay(mon_end_cal,day_end_cal,year_end_cal, hour_end_cal,min_end_cal,sec_end_cal)
EndIf Else Begin
If is_timerange_automatic_for_cal eq 1 Then Begin
  JulDay_beg_cal = Min(JulDay_vect_mag) > Min(JulDay_vect_spc)
  JulDay_end_cal = Max(JulDay_vect_mag) < Max(JulDay_vect_spc)
  CalDat, JulDay_beg_cal, mon_beg_cal, day_beg_cal, year_beg_cal, hour_beg_cal, min_beg_cal, sec_beg_cal
  CalDat, JulDay_end_cal, mon_end_cal, day_end_cal, year_end_cal, hour_end_cal, min_end_cal, sec_end_cal
EndIf
EndElse
TimeRange_cal_str  = '(time='+$
                      String(hour_beg_cal,format='(I2.2)')+String(min_beg_cal,format='(I2.2)')+String(sec_beg_cal,format='(I2.2)')+'-'+$
                      String(hour_end_cal,format='(I2.2)')+String(min_end_cal,format='(I2.2)')+String(sec_end_cal,format='(I2.2)')+')'

;;--
sub_tmp = Where(JulDay_vect_mag ge JulDay_beg_cal and JulDay_vect_mag le JulDay_end_cal)
JulDay_vect_cal  = JulDay_vect_mag[sub_tmp]
Bx_RTN_vect_cal  = Bx_RTN_vect[sub_tmp]
By_RTN_vect_cal  = By_RTN_vect[sub_tmp]
Bz_RTN_vect_cal  = Bz_RTN_vect[sub_tmp]
;;--
Np_RTN_vect_cal  = Interpol(Np_RTN_vect, JulDay_vect_spc, JulDay_vect_cal)
Wp_RTN_vect_cal  = Interpol(Wp_RTN_vect, JulDay_vect_spc, JulDay_vect_cal)
Vpx_RTN_vect_cal = Interpol(Vpx_RTN_vect, JulDay_vect_spc, JulDay_vect_cal)
Vpy_RTN_vect_cal = Interpol(Vpy_RTN_vect, JulDay_vect_spc, JulDay_vect_cal)
Vpz_RTN_vect_cal = Interpol(Vpz_RTN_vect, JulDay_vect_spc, JulDay_vect_cal)
;;--
Ex_SC_RTN_vect_cal = -(Vpy_RTN_vect_cal*Bz_RTN_vect_cal-Vpz_RTN_vect_cal*By_RTN_vect_cal) * 1.e-3
Ey_SC_RTN_vect_cal = -(Vpz_RTN_vect_cal*Bx_RTN_vect_cal-Vpx_RTN_vect_cal*Bz_RTN_vect_cal) * 1.e-3
Ez_SC_RTN_vect_cal = -(Vpx_RTN_vect_cal*By_RTN_vect_cal-Vpy_RTN_vect_cal*Bx_RTN_vect_cal) * 1.e-3
;;--
Vpx_RTN_aver_cal = Mean(Vpx_RTN_vect_cal,/NaN)
Vpy_RTN_aver_cal = Mean(Vpy_RTN_vect_cal,/NaN)
Vpz_RTN_aver_cal = Mean(Vpz_RTN_vect_cal,/NaN)
;;--
Ex_conv_RTN_vect_cal = -(Vpy_RTN_aver_cal*Bz_RTN_vect_cal-Vpz_RTN_aver_cal*By_RTN_vect_cal) * 1.e-3
Ey_conv_RTN_vect_cal = -(Vpz_RTN_aver_cal*Bx_RTN_vect_cal-Vpx_RTN_aver_cal*Bz_RTN_vect_cal) * 1.e-3
Ez_conv_RTN_vect_cal = -(Vpx_RTN_aver_cal*By_RTN_vect_cal-Vpy_RTN_aver_cal*Bx_RTN_vect_cal) * 1.e-3
;;--
Ex_RTN_vect_cal = Ex_SC_RTN_vect_cal - Ex_conv_RTN_vect_cal
Ey_RTN_vect_cal = Ey_SC_RTN_vect_cal - Ey_conv_RTN_vect_cal
Ez_RTN_vect_cal = Ez_SC_RTN_vect_cal - Ez_conv_RTN_vect_cal


Step3:
;===========================
;Step3:
;;--
time_vect = (JulDay_vect_cal - JulDay_vect_cal[0])*(24.*60*60)
dtime     = time_vect[1] - time_vect[0]
time_interval = Max(time_vect) - Min(time_vect)
num_times = N_Elements(time_vect)
num_periods = 16L
period_min= dtime*2.0
period_max= 300.0 < (time_interval/6) ;[s]
period_range  = [period_min, period_max]
period_range  = [10,1000]
period_range_str = '(Period='+$
  Strtrim(String(period_range[0],format='(F8.2)'),2)+'-'+$
  Strtrim(String(period_range[1],format='(F8.2)'),2)+')'

If is_execute_low_filter eq 1 Then Begin
  period_min = period_range[0]
  Smooth_Width = Floor(period_min/dtime/4) - (Floor(period_min/dtime/4)+1) mod 2   ;odd points
  Bx_RTN_vect_smooth = Smooth(Bx_RTN_vect_cal, Smooth_Width, /NaN)
  By_RTN_vect_smooth = Smooth(By_RTN_vect_cal, Smooth_Width, /NaN)
  Bz_RTN_vect_smooth = Smooth(Bz_RTN_vect_cal, Smooth_Width, /NaN)
  Ex_RTN_vect_smooth = Smooth(Ex_RTN_vect_cal, Smooth_Width, /NaN)
  Ey_RTN_vect_smooth = Smooth(Ey_RTN_vect_cal, Smooth_Width, /NaN)
  Ez_RTN_vect_smooth = Smooth(Ez_RTN_vect_cal, Smooth_Width, /NaN) 
  Np_RTN_vect_smooth = Smooth(Np_RTN_vect_cal, Smooth_Width, /NaN)
  Vpx_RTN_vect_smooth = Smooth(Vpx_RTN_vect_cal, Smooth_Width, /NaN)
  Vpy_RTN_vect_smooth = Smooth(Vpy_RTN_vect_cal, Smooth_Width, /NaN)
  Vpz_RTN_vect_smooth = Smooth(Vpz_RTN_vect_cal, Smooth_Width, /NaN)
  JulDay_vect_cal = JulDay_vect_cal[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Bx_RTN_vect_cal = Bx_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  By_RTN_vect_cal = By_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Bz_RTN_vect_cal = Bz_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Bt_RTN_vect_cal = Sqrt(Bx_RTN_vect_cal^2.0+By_RTN_vect_cal^2.0+Bz_RTN_vect_cal^2.0)
  Ex_RTN_vect_cal = Ex_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Ey_RTN_vect_cal = Ey_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Ez_RTN_vect_cal = Ez_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Np_RTN_vect_cal = Np_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Vpx_RTN_vect_cal = Vpx_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Vpy_RTN_vect_cal = Vpy_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
  Vpz_RTN_vect_cal = Vpz_RTN_vect_smooth[Indgen(num_times/Smooth_Width)*Smooth_Width]
Endif

;;--
time_vect = (JulDay_vect_cal - JulDay_vect_cal[0])*(24.*60*60)
dtime     = time_vect[1] - time_vect[0]
time_interval = Max(time_vect) - Min(time_vect)
num_periods = 16L
num_times   = N_Elements(time_vect)


Step3_1:
;===========================
;Step3_1:
;
;;--calculate wavlet_Bx/By/Bz_arr
For i=0,2 Do Begin
  If i eq 0 Then wave_vect = Bx_RTN_vect_cal
  If i eq 1 Then wave_vect = By_RTN_vect_cal
  If i eq 2 Then wave_vect = Bz_RTN_vect_cal
  get_Wavelet_Transform_of_BComp_vect_STEREO_v3, $
    time_vect, wave_vect, $    ;input
    period_range=period_range, $  ;input
    num_periods=num_periods, $
    Wavlet_arr, $       ;output
    time_vect_v2=time_vect_v2, $
    period_vect=period_vect
  PSD_arr  = Abs(wavlet_arr)^2 * dtime *2
  If i eq 0 Then Begin
    wavlet_Bx_arr=wavlet_arr & PSD_Bx_arr=PSD_arr
  EndIf
  If i eq 1 Then Begin
    wavlet_By_arr=wavlet_arr & PSD_By_arr=PSD_arr
  EndIf
  If i eq 2 Then Begin
    wavlet_Bz_arr=wavlet_arr & PSD_Bz_arr=PSD_arr
  EndIf
EndFor
;;--calculate wavlet_Ex/Ey/Ez_arr
For i=0,2 Do Begin
  If i eq 0 Then wave_vect = Ex_RTN_vect_cal
  If i eq 1 Then wave_vect = Ey_RTN_vect_cal
  If i eq 2 Then wave_vect = Ez_RTN_vect_cal
  get_Wavelet_Transform_of_BComp_vect_STEREO_v3, $
    time_vect, wave_vect, $    ;input
    period_range=period_range, $  ;input
    num_periods=num_periods, $
    Wavlet_arr, $       ;output
    time_vect_v2=time_vect_v2, $
    period_vect=period_vect
  PSD_arr  = Abs(wavlet_arr)^2 * dtime *2
  If i eq 0 Then Begin
    wavlet_Ex_arr=wavlet_arr & PSD_Ex_arr=PSD_arr
  EndIf
  If i eq 1 Then Begin
    wavlet_Ey_arr=wavlet_arr & PSD_Ey_arr=PSD_arr
  EndIf
  If i eq 2 Then Begin
    wavlet_Ez_arr=wavlet_arr & PSD_Ez_arr=PSD_arr
  EndIf
EndFor
;;--calculate wavlet_Vpx/Vpy/Vpz_arr
For i=0,2 Do Begin
  If i eq 0 Then wave_vect = Vpx_RTN_vect_cal
  If i eq 1 Then wave_vect = Vpy_RTN_vect_cal
  If i eq 2 Then wave_vect = Vpz_RTN_vect_cal
  get_Wavelet_Transform_of_BComp_vect_STEREO_v3, $
    time_vect, wave_vect, $    ;input
    period_range=period_range, $  ;input
    num_periods=num_periods, $
    Wavlet_arr, $       ;output
    time_vect_v2=time_vect_v2, $
    period_vect=period_vect
  PSD_arr  = Abs(wavlet_arr)^2 * dtime *2
  If i eq 0 Then Begin
    wavlet_Vx_arr=wavlet_arr & PSD_Vx_arr=PSD_arr
  EndIf
  If i eq 1 Then Begin
    wavlet_Vy_arr=wavlet_arr & PSD_Vy_arr=PSD_arr
  EndIf
  If i eq 2 Then Begin
    wavlet_Vz_arr=wavlet_arr & PSD_Vz_arr=PSD_arr
  EndIf
EndFor
;;--calculate wavlet_Np_arr
wave_vect = Np_RTN_vect_cal
get_Wavelet_Transform_of_BComp_vect_STEREO_v3, $
  time_vect, wave_vect, $    ;input
  period_range=period_range, $  ;input
  num_periods=num_periods, $
  Wavlet_arr, $       ;output
  time_vect_v2=time_vect_v2, $
  period_vect=period_vect
  PSD_arr  = Abs(wavlet_arr)^2 * dtime *2
wavlet_Np_arr=wavlet_arr & PSD_Np_arr=PSD_arr
 

;;--
Bxyz_RTN_arr_cal = [[Bx_RTN_vect_cal],[By_RTN_vect_cal],[Bz_RTN_vect_cal]]
Bxyz_RTN_arr_cal = Transpose(Bxyz_RTN_arr_cal)
is_convol_smooth = 1
get_LocalBG_of_MagField_at_Scales_WIND_MFI, $
  time_vect, Bxyz_RTN_arr_cal, $ ;input
  period_range=period_range, $  ;input
  num_periods=num_periods, $;input
  is_convol_smooth=is_convol_smooth, $ ;input
  Bxyz_LBG_RTN_arr, $   ;output
  period_vect=period_vect, $    ;output
  time_vect_v2=time_vect_v2


Step4:
;===========================
;Step4:
;;--
get_WavePara_BasedOn_SVD_of_EM_Sequence_subroutine, $
  wavlet_Bx_arr, wavlet_By_arr, wavlet_Bz_arr, $
  wavlet_Ex_arr, wavlet_Ey_arr, wavlet_Ez_arr, $ ;Ex/y/z in the PL-frame
  time_vect, period_vect, $
  Bxyz_LBG_RTN_arr, $  ;input
  EigVal_arr, EigVect_arr, $  ;output
  PlanarityPolarization_arr=PlanPolar_arr, $
  EplipticPolarization_arr=ElipPolar_arr, $
  SensePolarization_arr=SensePolar_arr, $
  SensePolar_E_arr=SensePolar_E_arr, $
  DegreePolarization_arr=DegreePolar_arr, $
  ;d      RefraIndex_arr=RefraIndex_arr
  k_over_omega_arr=k_over_omega_arr       ;unit: s/m
;;--
k_over_omega_in_PL_frame_s2m_arr = k_over_omega_arr
Vxyz_aver_in_SC_frame_kmps_vect = [Vpx_RTN_aver_cal,Vpy_RTN_aver_cal,Vpz_RTN_aver_cal]
get_Vphase_in_FlowFrame_after_SVD_of_EM_sequence_subroutine, $
  time_vect, period_vect, $
  k_over_omega_in_PL_frame_s2m_arr, $
  Vxyz_aver_in_SC_frame_kmps_vect=Vxyz_aver_in_SC_frame_kmps_vect, $
  Vphase_In_FLowFrame_kmps_arr=Vphase_In_FLowFrame_kmps_arr, $
  Omega_in_FLowFrame_rad2s_arr=Omega_in_FLowFrame_rad2s_arr, $
  kx_arr=kx_arr, ky_arr=ky_arr, kz_arr=kz_arr
;;--
get_PropAngle_PolarAngle_BasedOn_SVD_of_EM_Sequence_subroutine, $
  time_vect, period_vect, $
  EigVect_arr, Bxyz_LBG_RTN_arr, $
  theta_k_db_arr, theta_k_b0_arr, theta_db_b0_arr
;;--
Vphase_arr = Vphase_In_FLowFrame_kmps_arr
get_AbsVphase_PropAngle_BasedOn_SVD_of_EM_sequence_subroutine, $
  time_vect, period_vect, $ ;input
  Vphase_arr, Bxyz_LBG_RTN_arr, $ ;input
  AbsVphase_arr, theta_Vph_b0_arr ;output


Step5:
;===========================
;Step5:
get_Mode_Composition_based_On_Mode_Recognition_Method_For_MHD_Waves, $
  JulDay_vect_cal, period_vect, $
  Bt_RTN_vect_cal, Np_RTN_vect_cal, Wp_RTN_vect_cal, $
  wavlet_Bx_arr, wavlet_By_arr, wavlet_Bz_arr, $
  wavlet_Vx_arr, wavlet_Vy_arr, wavlet_Vz_arr, $
  wavlet_Np_arr, $
  Bxyz_LBG_RTN_arr=Bxyz_LBG_RTN_arr, $
  k_over_omega_arr=k_over_omega_arr, $
  Frac_alf_fw_arr=Frac_alf_fw_arr, Frac_alf_bw_arr=Frac_alf_bw_arr, $
  Frac_fast_fw_arr=Frac_fast_fw_arr, Frac_fast_bw_arr=Frac_fast_bw_arr, $
  Frac_slow_fw_arr=Frac_slow_fw_arr, Frac_slow_bw_arr=Frac_slow_bw_arr


Step6:
;===========================
;Step6:
;;--
dir_save = PSP_Data_Dir
TimeRange_save_str = TimeRange_cal_str
file_save = 'Composition_alf_fast_slow_fw_bw'+spc_v_str+'(PSP)'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_save_str+period_range_str+$
  '.sav'
data_descrip = 'got from "get_Fractional_Composition_of_MHD_modes_MainProgram.pro"'
Save, FileName=dir_save+file_save, $
  data_descrip, $
  JulDay_vect_cal, period_vect, $
  Bxyz_LBG_RTN_arr, $
  Frac_alf_fw_arr, Frac_alf_bw_arr, $
  Frac_fast_fw_arr, Frac_fast_bw_arr, $
  Frac_slow_fw_arr, Frac_slow_bw_arr


Step7:
;===========================
;Step7:
dir_data = PSP_Data_Dir
file_restore = 'Composition_alf_fast_slow_fw_bw'+spc_v_str+'(PSP)'+$
  '('+year_str+mon_str+day_str+')'+$
  '(time=*-*)'+'(Period=*-*)'+'.sav'
file_array  = File_Search(dir_data+file_restore, count=num_files)
For i_file=0,num_files-1 Do Begin
  Print, 'i_file, file: ', i_file, ': ', file_array[i_file]
EndFor
i_select  = 0
Read, 'i_select: ', i_select
file_restore  = file_array[i_select]
file_restore  = StrMid(file_restore, StrLen(dir_data), StrLen(file_restore)-StrLen(dir_data))
;;;---
Restore, dir_data+file_restore, /verbose
;data_descrip = 'got from "get_Fractional_Composition_of_MHD_modes_MainProgram.pro"'
;Save, FileName=dir_save+file_save, $
;  data_descrip, $
;  JulDay_vect_cal, period_vect, $
;  Frac_alf_fw_arr, Frac_alf_bw_arr, $
;  Frac_fast_fw_arr, Frac_fast_bw_arr, $
;  Frac_slow_fw_arr, Frac_slow_bw_arr


Step8:
;===========================
;Step8:
JulDay_vect_wavelet = JulDay_vect_cal
Print, 'is_timerange_automatic_plot (0 for defined by user, 1 for automatically inherited from original data): '
Print, is_timerange_automatic_for_plot
is_continue = ' '
Read, 'is_continue: ', is_continue
If is_timerange_automatic_for_plot eq 0 Then Begin
  hh_beg_plot_str = StrMid(hms_beg_plot_str,0,2) & mm_beg_plot_str = StrMid(hms_beg_plot_str,3,2) & ss_beg_plot_str = StrMid(hms_beg_plot_str,6,2)
  hh_end_plot_str = StrMid(hms_end_plot_str,0,2) & mm_end_plot_str = StrMid(hms_end_plot_str,3,2) & ss_end_plot_str = StrMid(hms_end_plot_str,6,2)
  year_beg_plot=Float(year_str) & mon_beg_plot=Float(mon_str) & day_beg_plot=Float(day_str)
  year_end_plot=Float(year_str) & mon_end_plot=Float(mon_str) & day_end_plot=Float(day_str)
  hour_beg_plot=Float(hh_beg_plot_str) & min_beg_plot=Float(mm_beg_plot_str) & sec_beg_plot=Float(ss_beg_plot_str)
  hour_end_plot=Float(hh_end_plot_str) & min_end_plot=Float(mm_end_plot_str) & sec_end_plot=Float(ss_end_plot_str)
  JulDay_beg_plot = JulDay(mon_beg_plot,day_beg_plot,year_beg_plot, hour_beg_plot,min_beg_plot,sec_beg_plot)
  JulDay_end_plot = JulDay(mon_end_plot,day_end_plot,year_end_plot, hour_end_plot,min_end_plot,sec_end_plot)
EndIf Else Begin
  If is_timerange_automatic_for_plot eq 1 Then Begin
    JulDay_beg_plot = Min(JulDay_vect_wavelet)
    JulDay_end_plot = Max(JulDay_vect_wavelet)
    CalDat, JulDay_beg_plot, mon_beg_plot, day_beg_plot, year_beg_plot, hour_beg_plot, min_beg_plot, sec_beg_plot
    CalDat, JulDay_end_plot, mon_end_plot, day_end_plot, year_end_plot, hour_end_plot, min_end_plot, sec_end_plot
  EndIf
EndElse
JulDay_range_plot = [JulDay_beg_plot, JulDay_end_plot]
;;;---
TimeRange_plot_str  = '(time='+$
  String(hour_beg_plot,format='(I2.2)')+String(min_beg_plot,format='(I2.2)')+String(sec_beg_plot,format='(I2.2)')+'-'+$
  String(hour_end_plot,format='(I2.2)')+String(min_end_plot,format='(I2.2)')+String(sec_end_plot,format='(I2.2)')+')'
period_range = [Min(period_vect),Max(period_vect)]
period_range_str = '(Period='+Strtrim(String(period_range[0],format='(f8.3)'),2)+'-'+$
  Strtrim(String(period_range[1],format='(f8.1)'),2)+')'


;;--
dir_fig = PSP_Figure_Dir
FileName = 'Composition_Spectra_alf_fast_slow_fw_bw'+spc_v_str+'(PSP)'+$
  TimeRange_plot_str+period_range_str
is_png_eps = 1
calling_program = 'get_Fractional_Composition_of_MHD_modes_MainProgram.pro'
TV_Composition_alf_fast_slow_fw_bw_subroutine, $ ;all variables are input
  JulDay_vect_wavelet, period_vect, $
  Frac_alf_fw_arr, Frac_alf_bw_arr, $
  Frac_fast_fw_arr, Frac_fast_bw_arr, $
  Frac_slow_fw_arr, Frac_slow_bw_arr, $
  JulDay_range_plot=JulDay_range_plot, $
  dir_fig=dir_fig, FileName=FileName, $
  is_png_eps=is_png_eps, calling_program=calling_program

End_Program:
End