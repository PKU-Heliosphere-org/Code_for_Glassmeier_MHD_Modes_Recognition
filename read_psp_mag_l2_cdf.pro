;Pro Read_PSP_MAG_L2_CDF
suite_str = 'fld'
level_str = 'l2'
payload_str = 'mag'
coord_str = 'rtn'
cadence_str = '';'_1min'; '', '_1min'
;;--
ymdh_str = '2022022512'
year_str = StrMid(ymdh_str,0,4)
mon_str  = StrMid(ymdh_str,4,2)
day_str  = StrMid(ymdh_str,6,2)
hour_str = StrMid(ymdh_str,8,2)
;;--
is_timerange_automatic = 1
is_timerange_automatic_for_plot = 1
If is_timerange_automatic eq 0 Then Begin
  If StrCmp(ymdh_str, '2018103100') eq 1 Then Begin
    hms_beg_save_str = '02:30:13'
    hms_end_save_str = '02:36:03'
  Endif
Endif
If is_timerange_automatic_for_plot eq 0 Then Begin
  If StrCmp(ymdh_str, '2018103100') eq 1 Then Begin
    hms_beg_plot_str = '02:30:13'
    hms_end_plot_str = '02:36:03'
  Endif
Endif
;;--
PSP_mag_Data_Dir = '/Users/psr/PycharmProjects/psr_spedas/pydata/psp_data/fields/'+$
  level_str +'/'+ payload_str +'_'+ coord_str + cadence_str +'/'+ year_str + '/'
PSP_Data_Dir = '/Users/psr/Desktop/'
PSP_Figure_Dir = '/Users/psr/Desktop/'


Step1:
;===========================
;Step1:
;;--
dir_read  = PSP_mag_Data_Dir
file_read = 'psp_'+suite_str+'_'+level_str+'_'+payload_str+'_'+coord_str+'_'+ $
  year_str+mon_str+day_str+hour_str+cadence_str+'_v**'+'.cdf'
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
CDF_Control, cdf_id, Variable='epoch_mag_RTN', Get_Var_Info=Info_Epoch
;a num_records  = Info_Epoch.MaxAllocRec
num_records   = Info_Epoch.MaxRec + 1L
CDF_VarGet, cdf_id, 'epoch_mag_RTN', Epoch_vect, Rec_Count=num_records
var_name_b_rtn = 'psp_'+suite_str+'_'+level_str+'_'+payload_str+'_'+'RTN'
CDF_VarGet, cdf_id, var_name_b_rtn, Bxyz_RTN_arr, Rec_Count=num_records
epoch_quality_flags = 'epoch_quality_flags'
CDF_VarGet, cdf_id, epoch_quality_flags, epoch_quality_flags, Rec_Count=num_records
psp_quality_flags = 'psp_'+suite_str+'_'+level_str+'_'+'quality_flags'
CDF_VarGet, cdf_id, psp_quality_flags, psp_quality_flags, Rec_Count=num_records
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


Step2:
;===========================
;Step2:
;;--
BadVal  = -1.e31
;;;---
Bx_RTN_vect  = Reform(Bxyz_RTN_arr[0,*])
sub_nan = Where((Bx_RTN_vect eq BadVal) or (Abs(Bx_RTN_vect) ge 800))
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where((Bx_RTN_vect ne BadVal) and (Abs(Bx_RTN_vect) lt 800))
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Bx_RTN_vect_v2 = Bx_RTN_vect[sub_val]
  Bx_RTN_vect  = Interpol(Bx_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Bx_RTN_vect(sub_nan)  = !values.f_nan
EndIf
sub_nan_Bx  = sub_nan
;;;---
By_RTN_vect  = Reform(Bxyz_RTN_arr[1,*])
sub_nan = Where((By_RTN_vect eq BadVal) or (Abs(By_RTN_vect) ge 800))
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where((By_RTN_vect ne BadVal) and (Abs(By_RTN_vect) lt 800))
  JulDay_vect_v2 = JulDay_vect[sub_val]
  By_RTN_vect_v2 = By_RTN_vect[sub_val]
  By_RTN_vect  = Interpol(By_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  By_RTN_vect(sub_nan)  = !values.f_nan
EndIf
sub_nan_By  = sub_nan
;;;---
Bz_RTN_vect  = Reform(Bxyz_RTN_arr[2,*])
sub_nan = Where((Bz_RTN_vect eq BadVal) or (Abs(Bz_RTN_vect) ge 800))
If (sub_nan[0] ne -1) Then Begin
  sub_val = Where((Bz_RTN_vect ne BadVal) and (Abs(Bz_RTN_vect) lt 800))
  JulDay_vect_v2 = JulDay_vect[sub_val]
  Bz_RTN_vect_v2 = Bz_RTN_vect[sub_val]
  Bz_RTN_vect  = Interpol(Bz_RTN_vect_v2, JulDay_vect_v2, JulDay_vect)
  ;  Bz_RTN_vect(sub_nan)  = !values.f_nan
EndIf
sub_nan_Bz  = sub_nan

;;;---
num_times = N_Elements(JulDay_vect)
flag_GoodVal_vect = Fltarr(num_times)+1.0
If (sub_nan_Bx[0] ne -1) Then flag_GoodVal_vect[sub_nan_Bx]=0.0
If (sub_nan_By[0] ne -1) Then flag_GoodVal_vect[sub_nan_By]=0.0
If (sub_nan_Bz[0] ne -1) Then flag_GoodVal_vect[sub_nan_Bz]=0.0
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
Bx_RTN_vect_save  = Bx_RTN_vect[sub_beg_save:sub_end_save]
By_RTN_vect_save  = By_RTN_vect[sub_beg_save:sub_end_save]
Bz_RTN_vect_save  = Bz_RTN_vect[sub_beg_save:sub_end_save]

;;--
num_times     = N_Elements(JulDay_vect_save)
dJulDay_vect  = JulDay_vect_save[1:num_times-1] - JulDay_vect_save[0:num_times-2]
dJulDay_interp    = Median(dJulDay_vect)
dJulDay_interp = 0.005/(24. * 60 * 60)
num_times_interp  = Floor((Max(JulDay_vect_save)-Min(JulDay_vect_save))/dJulDay_interp)+1
JulDay_vect_interp= Min(JulDay_vect_save)+Dindgen(num_times_interp)*dJulDay_interp
Bx_RTN_vect_interp= Interpol_NearBy_MacOS(Bx_RTN_vect_save, JulDay_vect_save, JulDay_vect_interp, NearBy=1)
By_RTN_vect_interp= Interpol_NearBy_MacOS(By_RTN_vect_save, JulDay_vect_save, JulDay_vect_interp, NearBy=1)
Bz_RTN_vect_interp= Interpol_NearBy_MacOS(Bz_RTN_vect_save, JulDay_vect_save, JulDay_vect_interp, NearBy=1)

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


;;--
dir_save  = PSP_Data_Dir
file_save = 'Bxyz_RTN_arr'+$
  '(psp_'+suite_str+'_'+level_str+'_'+payload_str+'_'+coord_str+cadence_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_save_str+$
  '.sav'
TimeRange_str = TimeRange_save_str
data_descrip  = 'got from "Read_PSP_MAG_L2_CDF.pro"'
Save, FileName=dir_save+file_save, $
  data_descrip, $
  TimeRange_str, $
  JulDay_vect_save, Bx_RTN_vect_save, By_RTN_vect_save, Bz_RTN_vect_save, $
  JulDay_vect_interp, Bx_RTN_vect_interp, By_RTN_vect_interp, Bz_RTN_vect_interp, $
  sub_beg_BadBins_vect, sub_end_BadBins_vect, $
  num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect

;;;---
dir_save  = PSP_Data_Dir
file_save = 'Bins_BadVal_DataGap'+$
  '(psp_'+suite_str+'_'+level_str+'_'+payload_str+'_'+coord_str+cadence_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_save_str+$
  '.sav'
TimeRange_str = TimeRange_save_str
data_descrip  = 'got from "Read_PSP_MAG_L2_CDF.pro"'
Save, FileName=dir_save+file_save, $
  data_descrip, $
  TimeRange_str, $
  JulDay_beg_BadBins_vect, JulDay_end_BadBins_vect, $
  num_DataGaps, JulDay_beg_DataGap_vect, JulDay_end_DataGap_vect

;;;--
AbsB_aver = Mean(Sqrt(Bx_RTN_vect_save^2 + By_RTN_vect_save^2 + Bz_RTN_vect_save^2))
Print, 'AbsB_aver [nT]: '
Print, AbsB_aver


Step4:
;===========================
;Step4:
num_times = N_Elements(JulDay_vect)
dJulDay_vect  = JulDay_vect[1:num_times-1] - JulDay_vect[0:num_times-2]
dTime_vect    = dJulDay_vect * (24.*60.*60)
;;--
Print, 'is_timerange_automatic_for_plot (0 for defined by user, 1 for automatically inherited from original data): '
Print, is_timerange_automatic_for_plot
is_continue = ' '
;Read, 'is_continue: ', is_continue
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
Bx_RTN_vect_plot = Bx_RTN_vect[sub_beg_plot:sub_end_plot]
By_RTN_vect_plot = By_RTN_vect[sub_beg_plot:sub_end_plot]
Bz_RTN_vect_plot = Bz_RTN_vect[sub_beg_plot:sub_end_plot]
dTime_vect    = dJulDay_vect[sub_beg_plot:sub_end_plot-1]*(24.*60*60)


Step5:
;===========================
;Step5:
is_png_eps = 1
If is_png_eps eq 2 Then Begin
  Set_Plot,'PS'
  xsize = 25.0
  ysize = 25.0
  Device, FileName=FileName_v2, XSize=xsize,YSize=ysize,/Color,Bits=8,/Encapsul
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
num_subimgs_y = 5
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
xplot_vect  = 0.5*(JulDay_vect_plot(0:num_times-2) + JulDay_vect_plot(1:num_times-1))
yplot_vect  = dTime_vect
xrange  = [Min(JulDay_vect_plot), Max(JulDay_vect_plot)]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
xticknames  = xticknames_time
xminor  = xminor_time
;xminor    = 6
yrange    = [Min(yplot_vect)-0.1*(Max(yplot_vect)-Min(yplot_vect)),Max(yplot_vect)+0.1*(Max(yplot_vect)-Min(yplot_vect))]
yrange    = [0.,yrange[1]*15]
xtitle    = year_str+'/'+mon_str+'/'+day_str
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
yplot_vect  = Bz_RTN_vect_plot
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
ytitle    = 'Bn_RTN (nT)'
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
yplot_vect  = By_RTN_vect_plot
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
ytitle    = 'Bt_RTN (nT)'
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
yplot_vect  = Bx_RTN_vect_plot
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
ytitle    = 'Br_RTN (nT)'
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
yplot_vect  = Sqrt(Bx_RTN_vect_plot^2+By_RTN_vect_plot^2+Bz_RTN_vect_plot^2)
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
ytitle    = '|B| (nT)'
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  Charsize=charsize,Charthick=charthick,Thick=thick,xthick=xthick,ythick=ythick,$
  XTitle=xtitle,YTitle=ytitle,$
  Color=color_black,$
  /NoErase,Font=-1
;;--
AnnotStr_tmp  = 'got from "Read_PSP_MAG_L2_CDF.pro"'
AnnotStr_arr  = [AnnotStr_tmp]
num_strings     = N_Elements(AnnotStr_arr)
For i_str=0,num_strings-1 Do Begin
  position_v1   = [position_img[0],position_img[1]/(num_strings+2)*(i_str+1)]
  CharSize    = 0.95
  XYOuts,position_v1[0],position_v1[1],AnnotStr_arr[i_str],/Normal,$
    CharSize=charsize,color=color_black,Font=-1
EndFor

;;--
image_tvrd  = TVRD(true=1)
dir_fig   = PSP_Figure_Dir
file_fig  = 'Bx&By&Bz_RTN'+$
  '(psp_'+suite_str+'_'+level_str+'_'+payload_str+'_'+coord_str+cadence_str+')'+$
  '('+year_str+mon_str+day_str+')'+$
  TimeRange_plot_str+$
  '.png'
Write_PNG, dir_fig+file_fig, image_tvrd; tvrd(/true), r,g,b

End_Program:
End
