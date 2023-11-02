;Pro Read_PSP_SPC_L3_CDF_with_optimization
suite_str = 'swp'
level_str = 'l3i';l2i,;l3i
pre_level_str = StrMid(level_str,0,2)
payload_str = 'spc'
;;--
ymd_str = '20190402'
year_str = StrMid(ymd_str,0,4)
mon_str  = StrMid(ymd_str,4,2)
day_str  = StrMid(ymd_str,6,2)
;;--
is_timerange_automatic = 1
is_timerange_automatic_for_plot = 1
If is_timerange_automatic eq 0 Then Begin
  If StrCmp(ymd_str, '20181031') eq 1 Then Begin
    hms_beg_save_str = '02:30:13'
    hms_end_save_str = '02:36:03'
  Endif
Endif
If is_timerange_automatic_for_plot eq 0 Then Begin
  If StrCmp(ymd_str, '20181101') eq 1 Then Begin
    hms_beg_plot_str = '16:27:00'
    hms_end_plot_str = '16:32:00'
  Endif
Endif
;;--
PSP_spc_Data_Dir = '/Volumes/Elements/PSP_Data_Analysis/Data/sweap/'+$
  payload_str +'/'+ pre_level_str +'/'+ level_str +'/'+ year_str + '/'
PSP_Data_Dir = '/Volumes/Elements/PSP_Data_Analysis/savData/'+$
  year_str +'-'+ mon_str +'-'+ day_str +'/'
PSP_Figure_Dir = '/Volumes/Elements/PSP_Data_Analysis/Figures/'+$
  year_str +'-'+ mon_str +'-'+ day_str +'/'

is_rtn_or_sc = 1 ;1 for rtn, 2 for sc
coord_str = is_rtn_or_sc eq 1?'RTN':'SC'
Step1:
;===========================
;Step1:
;;--
dir_read  = PSP_spc_Data_Dir
file_read = 'psp_'+suite_str+'_'+payload_str+'_'+level_str+'_'+ $
  year_str+mon_str+day_str+'_v**'+'.cdf'
file_array  = File_Search(dir_read+file_read, count=num_files)
For i_file=0,num_files-1 Do Begin
  Print, 'i_file, file: ', i_file, ': ', file_array[i_file]
Endfor
i_select  = 0
Read, 'i_select: ', i_select
file_read = file_array[i_select]
file_read = StrMid(file_read, StrLen(dir_read),StrLen(file_read)-StrLen(dir_read))
;;--
CD, Current=wk_dir
CD, dir_read
cdf_id  = CDF_Open(file_read)
;;--
CDF_Control, cdf_id, Variable='Epoch', Get_Var_Info=Info_Epoch
;a num_records  = Info_Epoch.MaxAllocRec
num_records   = Info_Epoch.MaxRec + 1L
CDF_VarGet, cdf_id, 'Epoch', Epoch_vect, Rec_Count=num_records
var_name_np = 'np_' + 'moment'
CDF_VarGet, cdf_id, var_name_np, Np_RTN_vect, Rec_Count=num_records
var_name_wp = 'wp_' + 'moment'
CDF_VarGet, cdf_id, var_name_wp, Wp_RTN_vect, Rec_Count=num_records
var_name_vp = 'vp_' + 'moment' + '_' + coord_str
CDF_VarGet, cdf_id, var_name_vp, Vp_RTN_arr, Rec_Count=num_records
var_name_sc_pos = 'sc_pos_HCI'
CDF_VarGet, cdf_id, var_name_sc_pos, SC_pos_HCI_arr, Rec_Count=num_records
var_name_sc_vel = 'sc_vel_HCI'
CDF_VarGet, cdf_id, var_name_sc_vel, SC_vel_HCI_arr, Rec_Count=num_records
var_name_np_dh = 'np_' + 'moment' + '_deltahigh'
CDF_VarGet, cdf_id, var_name_np_dh, Np_deltahigh_RTN_vect, Rec_Count=num_records
var_name_np_dl = 'np_' + 'moment' + '_deltalow'
CDF_VarGet, cdf_id, var_name_np_dl, Np_deltalow_RTN_vect, Rec_Count=num_records
var_name_wp_dh = 'wp_' + 'moment' + '_deltahigh'
CDF_VarGet, cdf_id, var_name_wp_dh, Wp_deltahigh_RTN_vect, Rec_Count=num_records
var_name_wp_dl = 'wp_' + 'moment' + '_deltalow'
CDF_VarGet, cdf_id, var_name_wp_dl, Wp_deltalow_RTN_vect, Rec_Count=num_records
var_name_vp_dh = 'vp_' + 'moment' + '_' +coord_str+ '_deltahigh'
CDF_VarGet, cdf_id, var_name_vp_dh, Vp_deltahigh_RTN_arr, Rec_Count=num_records
var_name_vp_dl = 'vp_' + 'moment' + '_' +coord_str+ '_deltalow'
CDF_VarGet, cdf_id, var_name_vp_dl, Vp_deltalow_RTN_arr, Rec_Count=num_records
CDF_VarGet, cdf_id, 'general_flag', general_flag, Rec_Count=num_records
;CDF_VarGet, cdf_id, 'DQF', DQF, Rec_Count=num_records
;CDF_VarGet, cdf_id, 'DQF_flagnames', DQF_flagnames, Rec_Count=num_records
;;--
CDF_Close, cdf_id
CD, wk_dir
;;--
Epoch_vect = Reform(Epoch_vect)
epoch_beg   = Epoch_vect[0]
CDF_Epoch, epoch_beg, year_beg, mon_beg, day_beg, hour_beg, min_beg, sec_beg, milli_beg, $
  /Breakdown_Epoch
CalJulDay_method = 2
If CalJulDay_method eq 1 Then Begin ;have some problem!!
  JulDay_beg    = JulDay(mon_beg,day_beg,year_beg,hour_beg,min_beg, sec_beg+milli_beg*1.e-3)
  JulDay_vect  = JulDay_beg+(Epoch_vect-Epoch_beg)/(1.e3*24.*60.*60.)
EndIf Else Begin
  If CalJulDay_method eq 2 Then Begin
    CDF_Epoch, epoch_vect, year_vect, mon_vect, day_vect, hour_vect, min_vect, sec_vect, milli_vect, $
      /Breakdown_Epoch
    JulDay_vect = JulDay(mon_vect, day_vect, year_vect, hour_vect, min_vect, sec_vect+milli_vect/1.e3)
  EndIf
EndElse


Step2_1:
;===========================
;Step2_1:
;;--
BadVal  = -1.e31
;;;---
sub_nan = Where(Np_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Np_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Np_RTN_vect_v2 = Np_RTN_vect[sub_val]
  Np_RTN_vect  = Interpol(Np_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Np_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Np  = sub_nan
;;;---
sub_nan = Where(Wp_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Wp_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Wp_RTN_vect_v2 = Wp_RTN_vect[sub_val]
  Wp_RTN_vect  = Interpol(Wp_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Wp_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Wp  = sub_nan
;;;---
Vpx_RTN_vect  = Reform(Vp_RTN_arr[0,*])
sub_nan = Where(Vpx_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpx_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpx_RTN_vect_v2 = Vpx_RTN_vect[sub_val]
  Vpx_RTN_vect  = Interpol(Vpx_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpx_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpx  = sub_nan
;;;---
Vpy_RTN_vect  = Reform(Vp_RTN_arr[1,*])
sub_nan = Where(Vpy_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpy_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpy_RTN_vect_v2 = Vpy_RTN_vect[sub_val]
  Vpy_RTN_vect  = Interpol(Vpy_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpy_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpy  = sub_nan
;;;---
Vpz_RTN_vect  = Reform(Vp_RTN_arr[2,*])
sub_nan = Where(Vpz_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpz_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpz_RTN_vect_v2 = Vpz_RTN_vect[sub_val]
  Vpz_RTN_vect  = Interpol(Vpz_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpz_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpz  = sub_nan
;;;---
sub_nan = Where(Np_deltahigh_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Np_deltahigh_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Np_deltahigh_RTN_vect_v2 = Np_deltahigh_RTN_vect[sub_val]
  Np_deltahigh_RTN_vect  = Interpol(Np_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Np_deltahigh_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Np_deltahigh  = sub_nan
;;;---
sub_nan = Where(Wp_deltahigh_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Wp_deltahigh_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Wp_deltahigh_RTN_vect_v2 = Wp_deltahigh_RTN_vect[sub_val]
  Wp_deltahigh_RTN_vect  = Interpol(Wp_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Wp_deltahigh_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Wp_deltahigh  = sub_nan
;;;---
Vpx_deltahigh_RTN_vect  = Reform(Vp_deltahigh_RTN_arr[0,*])
sub_nan = Where(Vpx_deltahigh_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpx_deltahigh_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpx_deltahigh_RTN_vect_v2 = Vpx_deltahigh_RTN_vect[sub_val]
  Vpx_deltahigh_RTN_vect  = Interpol(Vpx_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpx_deltahigh_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpx_deltahigh  = sub_nan
;;;---
Vpy_deltahigh_RTN_vect  = Reform(Vp_deltahigh_RTN_arr[1,*])
sub_nan = Where(Vpy_deltahigh_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpy_deltahigh_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpy_deltahigh_RTN_vect_v2 = Vpy_deltahigh_RTN_vect[sub_val]
  Vpy_deltahigh_RTN_vect  = Interpol(Vpy_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpy_deltahigh_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpy_deltahigh  = sub_nan
;;;---
Vpz_deltahigh_RTN_vect  = Reform(Vp_deltahigh_RTN_arr[2,*])
sub_nan = Where(Vpz_deltahigh_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpz_deltahigh_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpz_deltahigh_RTN_vect_v2 = Vpz_deltahigh_RTN_vect[sub_val]
  Vpz_deltahigh_RTN_vect  = Interpol(Vpz_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpz_deltahigh_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpz_deltahigh  = sub_nan
;;;---
sub_nan = Where(Np_deltalow_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Np_deltalow_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Np_deltalow_RTN_vect_v2 = Np_deltalow_RTN_vect[sub_val]
  Np_deltalow_RTN_vect  = Interpol(Np_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Np_deltalow_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Np_deltalow  = sub_nan
;;;---
sub_nan = Where(Wp_deltalow_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Wp_deltalow_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Wp_deltalow_RTN_vect_v2 = Wp_deltalow_RTN_vect[sub_val]
  Wp_deltalow_RTN_vect  = Interpol(Wp_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Wp_deltalow_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Wp_deltalow  = sub_nan
;;;---
Vpx_deltalow_RTN_vect  = Reform(Vp_deltalow_RTN_arr[0,*])
sub_nan = Where(Vpx_deltalow_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpx_deltalow_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpx_deltalow_RTN_vect_v2 = Vpx_deltalow_RTN_vect[sub_val]
  Vpx_deltalow_RTN_vect  = Interpol(Vpx_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpx_deltalow_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpx_deltalow  = sub_nan
;;;---
Vpy_deltalow_RTN_vect  = Reform(Vp_deltalow_RTN_arr[1,*])
sub_nan = Where(Vpy_deltalow_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpy_deltalow_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpy_deltalow_RTN_vect_v2 = Vpy_deltalow_RTN_vect[sub_val]
  Vpy_deltalow_RTN_vect  = Interpol(Vpy_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpy_deltalow_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpy_deltalow  = sub_nan
;;;---
Vpz_deltalow_RTN_vect  = Reform(Vp_deltalow_RTN_arr[2,*])
sub_nan = Where(Vpz_deltalow_RTN_vect eq BadVal)
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where(Vpz_deltalow_RTN_vect ne BadVal)
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Vpz_deltalow_RTN_vect_v2 = Vpz_deltalow_RTN_vect[sub_val]
  Vpz_deltalow_RTN_vect  = Interpol(Vpz_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Vpz_deltalow_RTN_vect[sub_nan] = !values.f_nan
EndIf
sub_nan_Vpz_deltalow  = sub_nan

Step2_2:
;===========================
;Step2_2:
;= 0, good/nominal/condition not present/etc
;> 1, bad/problematic/condition present/etc
;= -1, status not determined ("don't know")
;< -1, status does not matter ("don't care")

;sub_good = Where((general_flag eq 0 and JulDay_vect lt JulDay(11,04,2018,04,00,00)) OR (JulDay_vect gt JulDay(11,04,2018,04,00,00)))
;sub_bad  = Where(general_flag ne 0 and JulDay_vect lt JulDay(11,04,2018,04,00,00))
sub_good = Where(general_flag eq 0)
sub_bad = Where(general_flag ne 0)
;;;---
If (sub_bad[0] ne -1) Then Begin
  JulDay_vect_v2 = JulDay_vect[sub_good]
  Np_RTN_vect_v2 = Np_RTN_vect[sub_good]
  Wp_RTN_vect_v2 = Wp_RTN_vect[sub_good]
  Vpx_RTN_vect_v2 = Vpx_RTN_vect[sub_good]
  Vpy_RTN_vect_v2 = Vpy_RTN_vect[sub_good]
  Vpz_RTN_vect_v2 = Vpz_RTN_vect[sub_good]
  Np_deltahigh_RTN_vect_v2 = Np_deltahigh_RTN_vect[sub_good]
  Wp_deltahigh_RTN_vect_v2 = Wp_deltahigh_RTN_vect[sub_good]
  Vpx_deltahigh_RTN_vect_v2 = Vpx_deltahigh_RTN_vect[sub_good]
  Vpy_deltahigh_RTN_vect_v2 = Vpy_deltahigh_RTN_vect[sub_good]
  Vpz_deltahigh_RTN_vect_v2 = Vpz_deltahigh_RTN_vect[sub_good]
  Np_deltalow_RTN_vect_v2 = Np_deltalow_RTN_vect[sub_good]
  Wp_deltalow_RTN_vect_v2 = Wp_deltalow_RTN_vect[sub_good]
  Vpx_deltalow_RTN_vect_v2 = Vpx_deltalow_RTN_vect[sub_good]
  Vpy_deltalow_RTN_vect_v2 = Vpy_deltalow_RTN_vect[sub_good]
  Vpz_deltalow_RTN_vect_v2 = Vpz_deltalow_RTN_vect[sub_good]
  sub_tmp = where(JulDay_vect ge min(JulDay_vect_v2) and JulDay_vect le max(JulDay_vect_v2))
  JulDay_vect_interp = JulDay_vect[sub_tmp]
  JulDay_vect = JulDay_vect_interp
  Np_RTN_vect  = Interpol(Np_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Wp_RTN_vect  = Interpol(Wp_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpx_RTN_vect  = Interpol(Vpx_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpy_RTN_vect  = Interpol(Vpy_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpz_RTN_vect  = Interpol(Vpz_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Np_deltahigh_RTN_vect  = Interpol(Np_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Wp_deltahigh_RTN_vect  = Interpol(Wp_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpx_deltahigh_RTN_vect  = Interpol(Vpx_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpy_deltahigh_RTN_vect  = Interpol(Vpy_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpz_deltahigh_RTN_vect  = Interpol(Vpz_deltahigh_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Np_deltalow_RTN_vect  = Interpol(Np_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Wp_deltalow_RTN_vect  = Interpol(Wp_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpx_deltalow_RTN_vect  = Interpol(Vpx_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpy_deltalow_RTN_vect  = Interpol(Vpy_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
  Vpz_deltalow_RTN_vect  = Interpol(Vpz_deltalow_RTN_vect_v2, JulDay_vect_v2, JulDay_vect_interp)
EndIf
;If (sub_bad[0] ne -1) Then Begin
;  Np_RTN_vect[sub_bad] = !values.f_nan
;  Wp_RTN_vect[sub_bad] = !values.f_nan
;  Vpx_RTN_vect[sub_bad] = !values.f_nan
;  Vpy_RTN_vect[sub_bad] = !values.f_nan
;  Vpz_RTN_vect[sub_bad] = !values.f_nan
;  Np_deltahigh_RTN_vect[sub_bad] = !values.f_nan
;  Wp_deltahigh_RTN_vect[sub_bad] = !values.f_nan
;  Vpx_deltahigh_RTN_vect[sub_bad] = !values.f_nan
;  Vpy_deltahigh_RTN_vect[sub_bad] = !values.f_nan
;  Vpz_deltahigh_RTN_vect[sub_bad] = !values.f_nan
;  Np_deltalow_RTN_vect[sub_bad] = !values.f_nan
;  Wp_deltalow_RTN_vect[sub_bad] = !values.f_nan
;  Vpx_deltalow_RTN_vect[sub_bad] = !values.f_nan
;  Vpy_deltalow_RTN_vect[sub_bad] = !values.f_nan
;  Vpz_deltalow_RTN_vect[sub_bad] = !values.f_nan
;Endif
;;;---
num_times = N_Elements(JulDay_vect)
flag_GoodVal_vect = Fltarr(num_times)+1.0
If (sub_bad[0]  ne -1) Then flag_GoodVal_vect[sub_bad]=0.0
flag_GoodVal_vect = [1.0, flag_GoodVal_vect]
diff_flag_vect = flag_GoodVal_vect[1:num_times] - flag_GoodVal_vect[0:num_times-1]
;;;;----
sub_diff_eq_m1  = Where(diff_flag_vect eq -1)
sub_diff_eq_p1  = Where(diff_flag_vect eq +1)
If (sub_diff_eq_m1[0] ne -1 and sub_diff_eq_p1[0] ne -1) Then Begin
  num_BadBins = N_Elements(sub_diff_eq_m1)
  sub_beg_BadBins_vect  = Lonarr(num_BadBins)
  sub_end_BadBins_vect  = Lonarr(num_BadBins)
  sub_beg_BadBins_vect  = sub_diff_eq_m1
  sub_end_BadBins_vect  = sub_diff_eq_p1
  JulDay_beg_BadBins_vect = JulDay_vect(sub_beg_BadBins_vect)
  JulDay_end_BadBins_vect = JulDay_vect(sub_end_BadBins_vect)
EndIf Else Begin
  sub_beg_BadBins_vect  = -1
  sub_end_BadBins_vect  = -1
  JulDay_beg_BadBins_vect = -1.0
  JulDay_end_BadBins_vect = -1.0
EndElse


Step3:
;===========================
;Step3:
Print, 'is_timerange_automatic (0 for defined by user, 1 for automatically inherited from original data): '
Print, is_timerange_automatic
If is_timerange_automatic eq 0 Then Begin
  hh_beg_save_str = StrMid(hms_beg_save_str,0,2) & hour_beg=Float(hh_beg_save_str)
  mm_beg_save_str = StrMid(hms_beg_save_str,3,2) & min_beg=Float(mm_beg_save_str)
  ss_beg_save_str = StrMid(hms_beg_save_str,6,2) & sec_beg=Float(ss_beg_save_str)
  hh_end_save_str = StrMid(hms_end_save_str,0,2) & hour_end=Float(hh_end_save_str)
  mm_end_save_str = StrMid(hms_end_save_str,3,2) & min_end=Float(mm_end_save_str)
  ss_end_save_str = StrMid(hms_end_save_str,6,2) & sec_end=Float(ss_end_save_str)
  year_beg_save=Float(year_str) & mon_beg_save=Float(mon_str) & day_beg_save=Float(day_str)
  year_end_save=Float(year_str) & mon_end_save=Float(mon_str) & day_end_save=Float(day_str)
  hour_beg_save=Float(hh_beg_save_str) & min_beg_save=Float(mm_beg_save_str) & sec_beg_save=Float(ss_beg_save_str)
  hour_end_save=Float(hh_end_save_str) & min_end_save=Float(mm_end_save_str) & sec_end_save=Float(ss_end_save_str)
  JulDay_beg_save = JulDay(mon_beg_save,day_beg_save,year_beg_save, hour_beg_save,min_beg_save,sec_beg_save)
  JulDay_end_save = JulDay(mon_end_save,day_end_save,year_end_save, hour_end_save,min_end_save,sec_end_save)
EndIf Else Begin
  If is_timerange_automatic eq 1 Then Begin
    JulDay_beg_save = Min(JulDay_vect)
    JulDay_end_save = Max(JulDay_vect)
    CalDat, JulDay_beg_save, mon_beg_save, day_beg_save, year_beg_save, hour_beg_save, min_beg_save, sec_beg_save
    CalDat, JulDay_end_save, mon_end_save, day_end_save, year_end_save, hour_end_save, min_end_save, sec_end_save
  EndIf
EndElse
;;;---
TimeRange_save_str  = '(time='+$
  String(hour_beg_save,format='(I2.2)')+String(min_beg_save,format='(I2.2)')+String(sec_beg_save,format='(I2.2)')+'-'+$
  String(hour_end_save,format='(I2.2)')+String(min_end_save,format='(I2.2)')+String(sec_end_save,format='(I2.2)')+')'

;;--
sub_beg_save = Where(JulDay_vect ge JulDay_beg_save)
sub_end_save = Where(JulDay_vect le JulDay_end_save)
sub_beg_save = sub_beg_save[0]
sub_end_save = sub_end_save(N_Elements(sub_end_save)-1)
;;--
JulDay_vect_save  = JulDay_vect[sub_beg_save:sub_end_save]
Np_RTN_vect_save  = Np_RTN_vect[sub_beg_save:sub_end_save]
Wp_RTN_vect_save  = Wp_RTN_vect[sub_beg_save:sub_end_save]
Vpx_RTN_vect_save  = Vpx_RTN_vect[sub_beg_save:sub_end_save]
Vpy_RTN_vect_save  = Vpy_RTN_vect[sub_beg_save:sub_end_save]
Vpz_RTN_vect_save  = Vpz_RTN_vect[sub_beg_save:sub_end_save]
Np_deltahigh_RTN_vect_save  = Np_deltahigh_RTN_vect[sub_beg_save:sub_end_save]
Wp_deltahigh_RTN_vect_save  = Wp_deltahigh_RTN_vect[sub_beg_save:sub_end_save]
Vpx_deltahigh_RTN_vect_save  = Vpx_deltahigh_RTN_vect[sub_beg_save:sub_end_save]
Vpy_deltahigh_RTN_vect_save  = Vpy_deltahigh_RTN_vect[sub_beg_save:sub_end_save]
Vpz_deltahigh_RTN_vect_save  = Vpz_deltahigh_RTN_vect[sub_beg_save:sub_end_save]
Np_deltalow_RTN_vect_save  = Np_deltalow_RTN_vect[sub_beg_save:sub_end_save]
Wp_deltalow_RTN_vect_save  = Wp_deltalow_RTN_vect[sub_beg_save:sub_end_save]
Vpx_deltalow_RTN_vect_save  = Vpx_deltalow_RTN_vect[sub_beg_save:sub_end_save]
Vpy_deltalow_RTN_vect_save  = Vpy_deltalow_RTN_vect[sub_beg_save:sub_end_save]
Vpz_deltalow_RTN_vect_save  = Vpz_deltalow_RTN_vect[sub_beg_save:sub_end_save]

;;--
dJulDay_vect  = JulDay_vect_save[1:num_times-1] - JulDay_vect_save[0:num_times-2]
dTime_vect    = dJulDay_vect * (24.*60.*60)
dTime_median  = Median(dTime_vect)
sub_DataGaps  = Where(dTime_vect ge 4*dTime_median)
If (sub_DataGaps[0] ne -1) Then Begin
  num_DataGaps  = N_Elements(sub_DataGaps)
  JulDay_beg_DataGap_vect = Dblarr(num_DataGaps)
  JulDay_end_DataGap_vect = Dblarr(num_DataGaps)
  For i_DataGap=0,num_DataGaps-1 Do Begin
    JulDay_beg_DataGap_vect[i_DataGap] = JulDay_vect_save[sub_DataGaps[i_DataGap]]
    JulDay_end_DataGap_vect[i_DataGap] = JulDay_vect_save[sub_DataGaps[i_DataGap]+1]
  EndFor
EndIf Else Begin
  num_DataGaps  = 0L
  JulDay_beg_DataGap_vect = -1.0
  JulDay_end_DataGap_vect = -1.0
EndElse

If is_rtn_or_sc eq 1 Then Begin
  ;;--
  dir_save  = PSP_Data_Dir
  file_save = 'Np_Wp_Vp_RTN_arr(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_vect_save, Np_RTN_vect_save, Wp_RTN_vect_save, $
    Vpx_RTN_vect_save, Vpy_RTN_vect_save, Vpz_RTN_vect_save, $
    sub_beg_BadBins_vect, sub_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
  ;;---
  dir_save  = PSP_Data_Dir
  file_save = 'Bins_BadVal_DataGap(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_beg_BadBins_vect, JulDay_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
  
  ;;;---
  dir_save  = PSP_Data_Dir
  file_save = 'Np_Wp_Vp_RTN_Uncertainty(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_vect_save, $
    Np_deltahigh_RTN_vect_save, Wp_deltahigh_RTN_vect_save, Vpx_deltahigh_RTN_vect_save, Vpy_deltahigh_RTN_vect_save, Vpz_deltahigh_RTN_vect_save, $
    Np_deltalow_RTN_vect_save, Wp_deltalow_RTN_vect_save, Vpx_deltalow_RTN_vect_save, Vpy_deltalow_RTN_vect_save, Vpz_deltalow_RTN_vect_save, $
    sub_beg_BadBins_vect, sub_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
End
If is_rtn_or_sc eq 2 Then Begin
  Np_SC_vect_save = Np_RTN_vect_save
  Wp_SC_vect_save = Wp_RTN_vect_save
  Vpx_SC_vect_save = Vpx_RTN_vect_save
  Vpy_SC_vect_save = Vpy_RTN_vect_save
  Vpz_SC_vect_save = Vpz_RTN_vect_save
  Np_deltahigh_SC_vect_save = Np_deltahigh_RTN_vect_save
  Wp_deltahigh_SC_vect_save = Wp_deltahigh_RTN_vect_save
  Vpx_deltahigh_SC_vect_save = Vpx_deltahigh_RTN_vect_save
  Vpy_deltahigh_SC_vect_save = Vpy_deltahigh_RTN_vect_save
  Vpz_deltahigh_SC_vect_save = Vpz_deltahigh_RTN_vect_save
  Np_deltalow_SC_vect_save = Np_deltalow_RTN_vect_save
  Wp_deltalow_SC_vect_save = Wp_deltalow_RTN_vect_save
  Vpx_deltalow_SC_vect_save = Vpx_deltalow_RTN_vect_save
  Vpy_deltalow_SC_vect_save = Vpy_deltalow_RTN_vect_save
  Vpz_deltalow_SC_vect_save = Vpz_deltalow_RTN_vect_save
  ;;--
  dir_save  = PSP_Data_Dir
  file_save = 'Np_Wp_Vp_SC_arr(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_vect_save, Np_SC_vect_save, Wp_SC_vect_save, $
    Vpx_SC_vect_save, Vpy_SC_vect_save, Vpz_SC_vect_save, $
    sub_beg_BadBins_vect, sub_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
  ;;---
  dir_save  = PSP_Data_Dir
  file_save = 'Bins_BadVal_DataGap(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_beg_BadBins_vect, JulDay_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect

  ;;;---
  dir_save  = PSP_Data_Dir
  file_save = 'Np_Wp_Vp_SC_Uncertainty(optimized)'+$
    '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
    '('+year_str+mon_str+day_str+')'+$
    TimeRange_save_str+$
    '.sav'
  TimeRange_str = TimeRange_save_str
  data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
  Save, FileName=dir_save+file_save, $
    data_descrip, $
    TimeRange_str, $
    JulDay_vect_save, $
    Np_deltahigh_SC_vect_save, Wp_deltahigh_SC_vect_save, Vpx_deltahigh_SC_vect_save, Vpy_deltahigh_SC_vect_save, Vpz_deltahigh_SC_vect_save, $
    Np_deltalow_SC_vect_save, Wp_deltalow_SC_vect_save, Vpx_deltalow_SC_vect_save, Vpy_deltalow_SC_vect_save, Vpz_deltalow_SC_vect_save, $
    sub_beg_BadBins_vect, sub_end_BadBins_vect, $
    num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect
End
;;;;---
;dir_save  = PSP_Data_Dir
;file_save = 'SC_pos_vel_HCI'+$
;  '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
;  '('+year_str+mon_str+day_str+')'+$
;  TimeRange_save_str+$
;  '.sav'
;TimeRange_str = TimeRange_save_str
;data_descrip  = 'got from "Read_PSP_SPC_L3_CDF.pro"'
;Save, FileName=dir_save+file_save, $
;  data_descrip, $
;  TimeRange_str, $
;  JulDay_vect, $
;  SC_pos_HCI_arr, SC_vel_HCI_arr

;;;---
Np_aver = Mean(Np_RTN_vect)
Wp_aver = Mean(Wp_RTN_vect)
Vp_aver = Mean(Sqrt(Vpx_RTN_vect^2 + Vpy_RTN_vect^2 + Vpz_RTN_vect^2))
Print, 'Np_aver [cm^-3], Wp_aver [km/s], Vp_aver [km/s]'
Print, Np_aver, Wp_aver, Vp_aver
;Print, general_flag


Step4:
;===========================
;Step4:
num_times = N_Elements(JulDay_vect)
dJulDay_vect  = JulDay_vect[1:num_times-1] - JulDay_vect[0:num_times-2]
dTime_vect    = dJulDay_vect * (24.*60.*60)
;;--
Print, 'is_timerange_automatic_for_plot (0 for defined by user, 1 for automatically inherited from original data): '
Print, is_timerange_automatic_for_plot
If is_timerange_automatic_for_plot eq 0 Then Begin
  hh_beg_plot_str = StrMid(hms_beg_plot_str,0,2) & hour_beg=Float(hh_beg_plot_str)
  mm_beg_plot_str = StrMid(hms_beg_plot_str,3,2) & min_beg=Float(mm_beg_plot_str)
  ss_beg_plot_str = StrMid(hms_beg_plot_str,6,2) & sec_beg=Float(ss_beg_plot_str)
  hh_end_plot_str = StrMid(hms_end_plot_str,0,2) & hour_end=Float(hh_end_plot_str)
  mm_end_plot_str = StrMid(hms_end_plot_str,3,2) & min_end=Float(mm_end_plot_str)
  ss_end_plot_str = StrMid(hms_end_plot_str,6,2) & sec_end=Float(ss_end_plot_str)
  year_beg_plot=Float(year_str) & mon_beg_plot=Float(mon_str) & day_beg_plot=Float(day_str)
  year_end_plot=Float(year_str) & mon_end_plot=Float(mon_str) & day_end_plot=Float(day_str)
  hour_beg_plot=Float(hh_beg_plot_str) & min_beg_plot=Float(mm_beg_plot_str) & sec_beg_plot=Float(ss_beg_plot_str)
  hour_end_plot=Float(hh_end_plot_str) & min_end_plot=Float(mm_end_plot_str) & sec_end_plot=Float(ss_end_plot_str)
  JulDay_beg_plot = JulDay(mon_beg_plot,day_beg_plot,year_beg_plot, hour_beg_plot,min_beg_plot,sec_beg_plot)
  JulDay_end_plot = JulDay(mon_end_plot,day_end_plot,year_end_plot, hour_end_plot,min_end_plot,sec_end_plot)
EndIf Else Begin
  If is_timerange_automatic_for_plot eq 1 Then Begin
    JulDay_beg_plot = Min(JulDay_vect)
    JulDay_end_plot = Max(JulDay_vect)
    CalDat, JulDay_beg_plot, mon_beg_plot, day_beg_plot, year_beg_plot, hour_beg_plot, min_beg_plot, sec_beg_plot
    CalDat, JulDay_end_plot, mon_end_plot, day_end_plot, year_end_plot, hour_end_plot, min_end_plot, sec_end_plot
  EndIf
EndElse
;;--
TimeRange_plot_str  = '(time='+$
  String(hour_beg_plot,format='(I2.2)')+String(min_beg_plot,format='(I2.2)')+String(sec_beg_plot,format='(I2.2)')+'-'+$
  String(hour_end_plot,format='(I2.2)')+String(min_end_plot,format='(I2.2)')+String(sec_end_plot,format='(I2.2)')+')'
;;--
sub_beg_plot = Where(JulDay_vect ge JulDay_beg_plot)
sub_end_plot = Where(JulDay_vect le JulDay_end_plot)
sub_beg_plot = Min(sub_beg_plot)
sub_end_plot = Max(sub_end_plot)
JulDay_vect_plot = JulDay_vect[sub_beg_plot:sub_end_plot]
Np_RTN_vect_plot  = Np_RTN_vect[sub_beg_plot:sub_end_plot]
Wp_RTN_vect_plot  = Wp_RTN_vect[sub_beg_plot:sub_end_plot]
Vpx_RTN_vect_plot = Vpx_RTN_vect[sub_beg_plot:sub_end_plot]
Vpy_RTN_vect_plot = Vpy_RTN_vect[sub_beg_plot:sub_end_plot]
Vpz_RTN_vect_plot = Vpz_RTN_vect[sub_beg_plot:sub_end_plot]
dTime_vect_plot = dJulDay_vect[sub_beg_plot:sub_end_plot-1]*(24.*60*60)


Step5:
;===========================
;Step5:
is_png_eps = 1
;;--
If is_png_eps eq 1 Then Begin
  file_version  = '.png'
EndIf Else Begin
  file_version  = '.eps'
EndElse
FileName  = 'Np_Wp_Vp_'+coord_str+'(optimized)'+$
  '(psp_'+suite_str+'_'+payload_str+'_'+level_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_plot_str
FileName = PSP_Figure_Dir + FileName + file_version

;;--
If is_png_eps eq 2 Then Begin
  Set_Plot,'PS'
  xsize = 25.0
  ysize = 25.0
  Device, FileName=FileName, XSize=xsize,YSize=ysize,/Color,Bits=8,/Encapsul
EndIf Else Begin
  If is_png_eps eq 1 Then Begin
    Set_Plot, 'X'
    Device,DeComposed=0;, /Retain
    xsize=1000.0 & ysize=900.0
    Window,2,XSize=xsize,YSize=ysize,Retain=2,/pixmap
  EndIf
EndElse

;;--
LoadCT,13
TVLCT,R,G,B,/Get
color_red = 255L
TVLCT,255L,0L,0L,color_red
color_green = 254L
TVLCT,0L,255L,0L,color_green
color_blue  = 253L
TVLCT,0L,0L,255L,color_blue
color_white = 252L
TVLCT,255L,255L,255L,color_white
color_black = 251L
TVLCT,0L,0L,0L,color_black
num_CB_color= 256-5
R=Congrid(R,num_CB_color)
G=Congrid(G,num_CB_color)
B=Congrid(B,num_CB_color)
TVLCT,R,G,B

;;--
color_bg    = color_white
!p.background = color_bg
Plot,[0,1],[0,1],XStyle=1+4,YStyle=1+4,/NoData  ;change the background

;;--
If is_png_eps eq 2 Then Begin
  thick   = 2.5
  xthick  = 2.5
  ythick  = 2.5
  charthick = 2.5
  charsize  = 1.2
EndIf
If is_png_eps eq 1 Then Begin
  thick   = 1.2
  xthick  = 1.2
  ythick  = 1.2
  charthick = 1.2
  charsize  = 1.5
EndIf

;;--
position_img  = [0.05,0.05,0.95,0.95]
num_subimgs_x = 1
num_subimgs_y = 6
dx_subimg   = (position_img[2]-position_img[0])/num_subimgs_x
dy_subimg   = (position_img[3]-position_img[1])/num_subimgs_y

;;--
i_subimg_x  = 0
i_subimg_y  = 0
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
num_times = N_Elements(JulDay_vect_plot)
xplot_vect  = 0.5*(JulDay_vect_plot[0:num_times-2] + JulDay_vect_plot[1:num_times-1])
yplot_vect  = dTime_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
xticknames  = xticknames_time
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
yrange    = [0.,yrange[1]]
xtitle    = 'Time'
ytitle    = 'dTime [s]'
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1
;;;---
dtime_aver = Mean(dTime_vect,/NaN) ;unit: s
xyouts_str = String(dtime_aver, format='(F10.5)')+' [s]'
xpos_xyouts= position_subplot[0]+0.2*(position_subplot[2]-position_subplot[0])
ypos_xyouts= position_subplot[1]+0.5*(position_subplot[3]-position_subplot[1])
xyouts, xpos_xyouts, ypos_xyouts, xyouts_str, CharSize=1.5, color=color_black, /Normal

;;--
i_subimg_x  = 0
i_subimg_y  = 1
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
xplot_vect  = JulDay_vect_plot
yplot_vect  = Wp_RTN_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
;xticknames  = xticknames_time
xticknames  = Replicate(' ', xticks+1)
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
xtitle    = ' '
ytitle    = TexToIDL('W_p (km/s)')
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1

;;--
i_subimg_x  = 0
i_subimg_y  = 2
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
xplot_vect  = JulDay_vect_plot
yplot_vect  = Np_RTN_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
;xticknames  = xticknames_time
xticknames  = Replicate(' ', xticks+1)
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
xtitle    = ' '
ytitle    =  TexToIDL('N_p (cm^{-3})')
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1

;;--
i_subimg_x  = 0
i_subimg_y  = 3
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
xplot_vect  = JulDay_vect_plot
yplot_vect  = Vpz_RTN_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
;xticknames  = xticknames_time
xticknames  = Replicate(' ', xticks+1)
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
xtitle    = ' '
ytitle    = is_rtn_or_sc eq 1 ? TexToIDL('V_{p,N} (km/s)'):TexToIDL('V_{p,Z} (km/s)')
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1

;;--
i_subimg_x  = 0
i_subimg_y  = 4
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
xplot_vect  = JulDay_vect_plot
yplot_vect  = Vpy_RTN_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
;xticknames  = xticknames_time
xticknames  = Replicate(' ', xticks+1)
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
xtitle    = ' '
ytitle    = is_rtn_or_sc eq 1 ? TexToIDL('V_{p,T} (km/s)'):TexToIDL('V_{p,Y} (km/s)')
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1

;;--
i_subimg_x  = 0
i_subimg_y  = 5
win_position= [position_img[0]+dx_subimg*i_subimg_x+0.10*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.10*dy_subimg,$
  position_img[0]+dx_subimg*i_subimg_x+0.90*dx_subimg,$
  position_img[1]+dy_subimg*i_subimg_y+0.90*dy_subimg]
position_subplot  = win_position
xplot_vect  = JulDay_vect_plot
yplot_vect  = Vpx_RTN_vect_plot
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
;xticknames  = xticknames_time
xticknames  = Replicate(' ', xticks+1)
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
xtitle    = ' '
ytitle    = is_rtn_or_sc eq 1 ? TexToIDL('V_{p,R} (km/s)'):TexToIDL('V_{p,X} (km/s)')
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1


;;--
AnnotStr_tmp  = 'got from "Read_PSP_SPC_L3_CDF_with_optimization.pro"'
AnnotStr_arr  = [AnnotStr_tmp]
num_strings     = N_Elements(AnnotStr_arr)
For i_str=0,num_strings-1 Do Begin
  position_v1   = [position_img[0],position_img[1]/(num_strings+2)*(i_str+1)]
  CharSize    = 0.95
  XYOuts,position_v1[0],position_v1[1],AnnotStr_arr[i_str],/Normal,$
    CharSize=charsize,color=color_black,Font=-1
EndFor

;;--
If is_png_eps eq 1 Then Begin
  image_tvrd  = TVRD(true=1)
  Write_PNG, FileName, image_tvrd; tvrd(/true), r,g,b
EndIf Else Begin
  If is_png_eps eq 2 Then Begin
    ;;;--
    Device,/Close
  EndIf
EndElse

End_Program:
End