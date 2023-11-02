Pro TV_Composition_alf_fast_slow_fw_bw_subroutine, $ ;all variables are input
  JulDay_vect_wavelet, period_vect, $
  Frac_alf_fw_arr, Frac_alf_bw_arr, $
  Frac_fast_fw_arr, Frac_fast_bw_arr, $
  Frac_slow_fw_arr, Frac_slow_bw_arr, $
  JulDay_range_plot=JulDay_range_plot, $
  dir_fig=dir_fig, FileName=FileName, $
  is_png_eps=is_png_eps, calling_program=calling_program


Step1:
;===========================
;Step1:
;;--
sub_beg_TV = Where(JulDay_vect_wavelet ge JulDay_range_plot[0])
sub_end_TV = Where(JulDay_vect_wavelet le JulDay_range_plot[1])
sub_beg_TV = Min(sub_beg_TV)
sub_end_TV = Max(sub_end_TV)
JulDay_vect_TV = JulDay_vect_wavelet[sub_beg_TV:sub_end_TV]
CalDat, JulDay_range_plot[0], mon_beg, day_beg, year_beg, hour_beg_TV, min_beg_TV, sec_beg_TV
CalDat, JulDay_range_plot[1], mon_end, day_end, year_end, hour_end_TV, min_end_TV, sec_end_TV
timestr_beg_TV  = String(hour_beg_TV,format='(I2.2)')+String(min_beg_TV,format='(I2.2)')+String(sec_beg_TV,format='(I2.2)')
timestr_end_TV  = String(hour_end_TV,format='(I2.2)')+String(min_end_TV,format='(I2.2)')+String(sec_end_TV,format='(I2.2)')
timerange_str_TV= '(time='+timestr_beg_TV+'-'+timestr_end_TV+')'


Frac_alf_fw_arr_TV = Frac_alf_fw_arr[sub_beg_TV:sub_end_TV,*]
Frac_alf_bw_arr_TV = Frac_alf_bw_arr[sub_beg_TV:sub_end_TV,*]
Frac_fast_fw_arr_TV = Frac_fast_fw_arr[sub_beg_TV:sub_end_TV,*]
Frac_fast_bw_arr_TV = Frac_fast_bw_arr[sub_beg_TV:sub_end_TV,*] 
Frac_slow_fw_arr_TV = Frac_slow_fw_arr[sub_beg_TV:sub_end_TV,*]
Frac_slow_bw_arr_TV = Frac_slow_bw_arr[sub_beg_TV:sub_end_TV,*]

num_times_TV = sub_end_TV - sub_beg_TV + 1
Frac_alf_fw_vect_plot = Mean(Frac_alf_fw_arr_TV,dimension=1,/nan)
Frac_alf_bw_vect_plot = Mean(Frac_alf_bw_arr_TV,dimension=1,/nan)
Frac_fast_fw_vect_plot = Mean(Frac_fast_fw_arr_TV,dimension=1,/nan)
Frac_fast_bw_vect_plot = Mean(Frac_fast_bw_arr_TV,dimension=1,/nan)
Frac_slow_fw_vect_plot = Mean(Frac_slow_fw_arr_TV,dimension=1,/nan)
Frac_slow_bw_vect_plot = Mean(Frac_slow_bw_arr_TV,dimension=1,/nan)


Step2:
;===========================
;Step2:

;;--
If is_png_eps eq 1 Then Begin
  file_version  = '.png'
EndIf Else Begin
  file_version  = '.eps'
EndElse
fig_note_str = '(CompositionSpectra_time_period)'
FileName_v2  = FileName+fig_note_str+file_version
FileName_v2  = dir_fig + FileName_v2

perp_symbol_oct = "170 ;"                           
perp_symbol_str = String(Byte(perp_symbol_oct))  
perp_symbol_str = '{!9' + perp_symbol_str + '!X}'

;;--
If is_png_eps eq 2 Then Begin
  Set_Plot,'PS'
  xsize = 28.0
  ysize = 24.0
  Device, FileName=FileName_v2, XSize=xsize,YSize=ysize,/Color,Bits=8,/Encapsul
EndIf Else Begin
If is_png_eps eq 1 Then Begin
  Set_Plot,'x'
  Device,DeComposed=0;, /Retain
  xsize=1000.0 & ysize=900.0
  Window,2,XSize=xsize,YSize=ysize,Retain=2,/pixmap
EndIf
EndElse


;;--
LoadCT,33;4
TVLCT,R,G,B,/Get
R=R(2:255) & G=G(2:255) & B=B(2:255)
;Restore, '/Work/Data Analysis/Programs/RainBow(reset).sav', /Verbose
;a n_colors  = 256
;a RainBow_Matlab, R,G,B, n_colors
color_red = 0L
TVLCT,255L,0L,0L,color_red
R_red=255L & G_red=0L & B_red=0L
color_green = 1L
TVLCT,0L,255L,0L,color_green
R_green=0L & G_green=255L & B_green=0L
color_blue  = 2L
TVLCT,0L,0L,255L,color_blue
R_blue=0L & G_blue=0L & B_blue=255L
color_white = 4L
TVLCT,255L,255L,255L,color_white
R_white=255L & G_white=255L & B_white=255L
color_black = 3L
TVLCT,0L,0L,0L,color_black
R_black=0L & G_black=0L & B_black=0L
num_CB_color= 256-5
R=Congrid(R,num_CB_color)
G=Congrid(G,num_CB_color)
B=Congrid(B,num_CB_color)
TVLCT,R,G,B
R = [R_red,R_green,R_blue,R_black,R_white,R]
G = [G_red,G_green,G_blue,G_black,G_white,G]
B = [B_red,B_green,B_blue,B_black,B_white,B]
TVLCT,R,G,B
color_badval = 4
;a num_CB_colors_gt0 = num_CB_color / 2
;a num_CB_colors_lt0 = num_CB_color - num_CB_colors_gt0
;a i_beg_CB_lt0 = 5
;a i_beg_CB_gt0 = i_beg_CB_lt0 + num_CB_colors_lt0


;;--
If is_png_eps eq 1 Then Begin
  color_bg    = color_white
  !p.background = color_bg
  Plot,[0,1],[0,1],XStyle=1+4,YStyle=1+4,/NoData  ;change the background
EndIf

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
charsize  = 1.2
EndIf



Step2_2:
;===========================
;Step2_2:

;;--
position_img  = [0.05,0.05,0.92,0.95]
num_subimgs_x = 1
num_subimgs_y = 6
panel_str_arr = StrArr(num_subimgs_y)
panel_str_arr = ['a','b','c','d','e','f']
dx_subimg   = (position_img[2]-position_img[0])/num_subimgs_x
dy_subimg   = (position_img[3]-position_img[1])/num_subimgs_y
;;--
x_margin_left = 0.10
x_margin_right= 0.95
y_margin_bot  = 0.05
y_margin_top  = 0.95

perp_symbol_oct = "170 ;"                           
perp_symbol_str = String(Byte(perp_symbol_oct))  
perp_symbol_str = '{!9' + perp_symbol_str + '!X}'

is_contour_or_TV  = 1

;;--
i_subimg_x = 0
For i_subimg_y=0,num_subimgs_y-1 Do Begin
  If (i_subimg_y eq num_subimgs_y-1) Then Begin
    image_TV  = Frac_alf_fw_arr_TV 
    title = TexToIDL('FW Alfven')
  EndIf
  If (i_subimg_y eq num_subimgs_y-2) Then Begin 
    image_TV  = Frac_alf_bw_arr_TV
    title = TexToIDL('BW Alfven')
  EndIf
  If (i_subimg_y eq num_subimgs_y-3) Then Begin 
    image_TV  = Frac_fast_fw_arr_TV
    title = TexToIDL('FW Fast')
  EndIf
  If (i_subimg_y eq num_subimgs_y-4) Then Begin 
    image_TV  = Frac_fast_bw_arr_TV
    title = TexToIDL('BW Fast')
  EndIf  
  If (i_subimg_y eq num_subimgs_y-5) Then Begin 
    image_TV  = Frac_slow_fw_arr_TV
    title = TexToIDL('FW Slow')
  EndIf
  If (i_subimg_y eq num_subimgs_y-6) Then Begin 
    image_TV  = Frac_slow_bw_arr_TV
    title = TexToIDL('BW Slow')
  EndIf  
 
;;--  
xplot_vect  = JulDay_vect_TV
yplot_vect  = period_vect
xrange  = [Min(xplot_vect)-0.5*(xplot_vect[1]-xplot_vect[0]), Max(xplot_vect)+0.5*(xplot_vect[1]-xplot_vect[0])]
xrange_time = xrange
get_xtick_for_time_MacOS, xrange_time, xtickv=xtickv_time, xticknames=xticknames_time, xminor=xminor_time
xtickv    = xtickv_time
xticks    = N_Elements(xtickv)-1
xticknames  = xticknames_time
If (i_subimg_y ne 0) Then Begin
  xticknames  = Replicate(' ',N_Elements(xtickv))
EndIf  
xminor  = xminor_time
;xminor    = 6
lg_yplot_vect = ALog10(yplot_vect)
yrange    = 10^[Min(lg_yplot_vect)-0.5*(lg_yplot_vect[1]-lg_yplot_vect[0]),$
                Max(lg_yplot_vect)+0.5*(lg_yplot_vect[1]-lg_yplot_vect[0])]
xtitle    = ' '
ytitle  = 'period [s]'

image_TV  = Rebin(image_TV,(Size(image_TV))[1],(Size(image_TV))[2]*1, /Sample)
yplot_vect= 10^Congrid(ALog10(yplot_vect), N_Elements(yplot_vect)*1, /Minus_One)

;;--
win_position= [position_img[0]+dx_subimg*i_subimg_x+x_margin_left*dx_subimg,$
        position_img[1]+dy_subimg*i_subimg_y+y_margin_bot*dy_subimg,$
        position_img[0]+dx_subimg*i_subimg_x+x_margin_right*dx_subimg,$
        position_img[1]+dy_subimg*i_subimg_y+y_margin_top*dy_subimg]
position_subplot  = win_position
position_SubImg   = position_SubPlot

;;;---
sub_BadVal  = Where(Finite(image_TV) eq 0)
If sub_BadVal[0] ne -1 Then Begin
  num_BadVal  = N_Elements(sub_BadVal)
  Print, 'num_BadVal: ', num_BadVal
  image_TV(sub_BadVal)  = -9999.0
EndIf Else Begin
  num_BadVal  = 0
EndElse
image_TV_v2 = image_TV(Sort(image_TV))
min_image = image_TV_v2(Long(0.10*N_Elements(image_TV))+num_BadVal)
max_image = image_TV_v2(Long(0.90*N_Elements(image_TV)))
;a min_image_v2 = Min([-Abs(min_image),-Abs(max_image)])
;a max_image_v2 = Max([+Abs(min_image),+Abs(max_image)])
;a min_image = min_image_v2
;a max_image = max_image_v2
min_image = 0.0
max_image = 1.0
byt_image_TV = BytSCL(image_TV, min=min_image, max=max_image, Top=num_CB_color-1)
byt_image_TV= byt_image_TV+(256-num_CB_color)
color_BadVal= color_white
If sub_BadVal[0] ne -1 Then $
byt_image_TV(sub_BadVal)  = color_BadVal


If is_contour_or_TV eq 1 Then Begin
num_levels  = 150
levels_vect = Byte(Findgen(num_levels)*Float(num_CB_color-1)/(num_levels-1))
level_val_vect= min_image + Float(levels_vect)/(num_CB_color-1)*(max_image-min_image)
levels_vect   = [color_BadVal, levels_vect+(256-num_CB_color)]
color_vect    = levels_vect
contour_arr = byt_image_TV
;;;---congrid to reduce the size of the figure
num_times  = N_Elements(xplot_vect)
num_periods = N_Elements(yplot_vect)
xplot_vect_v2 = Congrid(xplot_vect, num_times/20, /Interp)
contour_arr_v2 = Congrid(contour_arr, num_times/20, num_periods, /Interp)
;;;---
Contour, contour_arr_v2, xplot_vect_v2, yplot_vect, $
  XRange=xrange, YRange=yrange, Position=position_SubPlot, XStyle=1+4, YStyle=1+4, $
  /Cell_Fill, /NoErase, YLog=1, $
  Levels=levels_vect, C_Colors=color_vect, NoClip=0;, /OverPlot 
EndIf Else Begin
TVImage, byt_image_TV,Position=position_SubPlot, NOINTERPOLATION=1 
EndElse


Plot, xrange, yrange, XRange=xrange, YRange=yrange, XStyle=1+4, YStyle=1+4, $
    Position=position_subimg, XTitle=' ', YTitle=' ', /NoData, /NoErase, Color=color_black, $
    XTickLen=-0.02,YTickLen=-0.02, YLog=1, XThick=xthick,YThick=ythick,Thick=thick,CharSize=charsize,CharThick=charthick
    
;;;---
Plot,xplot_vect, yplot_vect,XRange=xrange,YRange=yrange,XStyle=1,YStyle=1,$
  Position=position_subplot,$
  XTicks=xticks,XTickV=xtickv,XTickName=xticknames,XMinor=xminor,XTickLen=0.04,$
  XTitle=xtitle,YTitle=ytitle,Title=' ',$ ;title,$
  Color=color_black,$
  /NoErase,/NoData, Font=-1, YLog=1,$
  XThick=xthick,YThick=ythick,Thick=thick,CharSize=charsize,CharThick=charthick
 

;;;---
xpos_tmp = position_subplot[0]-0.09
ypos_tmp = (position_subplot[1]+position_subplot[3])/2
xyouts_tmp = title ;+ TexToIDL('[W/m^3/Hz]')
XYOuts,xpos_tmp,ypos_tmp,xyouts_tmp, CharSize=charsize,CharThick=charthick*1.5,Color=color_black,/Normal, $
  Orientation=90.0, Alignment=0.5


;;;---
xpos_tmp = position_subplot[0]-0.08
ypos_tmp = position_subplot[3]
i_panel = i_subimg_x + (num_subimgs_y-1-i_subimg_y)*num_subimgs_x
panel_str_tmp = '('+panel_str_arr(i_panel)+')'
XYOuts,xpos_tmp,ypos_tmp,panel_str_tmp, CharSize=charsize,CharThick=charthick*1.5,Color=color_black,/Normal

If (i_subimg_y eq num_subimgs_y-1) Then Begin
position_CB   = [position_SubImg(2)+0.05,position_SubImg[1],$
                  position_SubImg(2)+0.06,position_SubImg(3)]
num_ticks   = 3
num_divisions = num_ticks-1
max_tickn   = max_image
min_tickn   = min_image
interv_ints = (max_tickn-min_tickn)/(num_ticks-1)
tickn_CB    = String((Findgen(num_ticks)*interv_ints+min_tickn),format='(F5.1)');the tick-names of colorbar 15
titleCB     = ' ';title
bottom_color  = 256-num_CB_color  ;0B
img_colorbar  = (Bytarr(20)+1B)#(Bindgen(num_CB_color)+bottom_color)
TVImage, img_colorbar,Position=position_CB, NOINTERPOLATION=1
;;;;----draw the outline of the color-bar
Plot,[min_image,max_image],[1,2],Position=position_CB,XStyle=1,YStyle=1,$
  XTicks=1,XTickName=[' ',' '],YTicks=num_ticks-1,YTickName=tickn_CB,Font=-1,$
  /NoData,/NoErase,Color=color_black, $
  TickLen=0.02,Title=' ',YTitle=titleCB, $
  XThick=xthick,YThick=ythick,CharSize=charsize,CharThick=charthick,Thick=thick
EndIf


 
EndFor ;For i_subimg_y=0,num_subimgs_y-1 Do Begin



;;--
AnnotStr_tmp  = 'got from "TV_Composition_alf_fast_slow_fw_bw_subroutine.pro"'
AnnotStr_arr  = [AnnotStr_tmp]
;d AnnotStr_arr  = [AnnotStr_arr, AnnotStr_tmp]
num_strings     = N_Elements(AnnotStr_arr)
For i_str=0,num_strings-1 Do Begin
  position_v1   = [position_img[0],position_img[1]/(num_strings+2)*(i_str+1)]
  CharSize    = 0.95
  XYOuts,position_v1[0],position_v1[1],AnnotStr_arr(i_str),/Normal,$
      CharSize=charsize,color=color_black,Font=-1
EndFor

;;--
If is_png_eps eq 1 Then Begin
image_tvrd  = TVRD(true=1)
Write_PNG, FileName_v2, image_tvrd; tvrd(/true), r,g,b
EndIf Else Begin
If is_png_eps eq 2 Then Begin
;;;--
Device,/Close
EndIf
EndElse



Step3:
;===========================
;Step3:

;;--
If is_png_eps eq 1 Then Begin
  file_version  = '.png'
EndIf Else Begin
  file_version  = '.eps'
EndElse
fig_note_str = '(CompositionSpectra_freq)'
FileName_v3  = FileName+fig_note_str+file_version
FileName_v3  = dir_fig + FileName_v3

perp_symbol_oct = "170 ;"                           
perp_symbol_str = String(Byte(perp_symbol_oct))  
perp_symbol_str = '{!9' + perp_symbol_str + '!X}'

;;--
If is_png_eps eq 2 Then Begin
  Set_Plot,'PS'
  xsize = 28.0
  ysize = 24.0
  Device, FileName=FileName_v3, XSize=xsize,YSize=ysize,/Color,Bits=8,/Encapsul
EndIf Else Begin
If is_png_eps eq 1 Then Begin
  Set_Plot,'x'
  Device,DeComposed=0;, /Retain
  xsize=600.0 & ysize=450.0
  Window,2,XSize=xsize,YSize=ysize,Retain=2,/pixmap
EndIf
EndElse


;;--
LoadCT,16;4
TVLCT,R,G,B,/Get
;Restore, '/Work/Data Analysis/Programs/RainBow(reset).sav', /Verbose
;a n_colors  = 256
;a RainBow_Matlab, R,G,B, n_colors
color_red = 0L
TVLCT,255L,0L,0L,color_red
R_red=255L & G_red=0L & B_red=0L
color_green = 1L
TVLCT,0L,255L,0L,color_green
R_green=0L & G_green=255L & B_green=0L
color_blue  = 2L
TVLCT,0L,0L,255L,color_blue
R_blue=0L & G_blue=0L & B_blue=255L
color_white = 4L
TVLCT,255L,255L,255L,color_white
R_white=255L & G_white=255L & B_white=255L
color_black = 3L
TVLCT,0L,0L,0L,color_black
R_black=0L & G_black=0L & B_black=0L
num_CB_color= 256-5
R=Congrid(R,num_CB_color)
G=Congrid(G,num_CB_color)
B=Congrid(B,num_CB_color)
TVLCT,R,G,B
R = [R_red,R_green,R_blue,R_black,R_white,R]
G = [G_red,G_green,G_blue,G_black,G_white,G]
B = [B_red,B_green,B_blue,B_black,B_white,B]
TVLCT,R,G,B
color_badval = 4
;a num_CB_colors_gt0 = num_CB_color / 2
;a num_CB_colors_lt0 = num_CB_color - num_CB_colors_gt0
;a i_beg_CB_lt0 = 5
;a i_beg_CB_gt0 = i_beg_CB_lt0 + num_CB_colors_lt0


;;--
If is_png_eps eq 1 Then Begin
  color_bg    = color_white
  !p.background = color_bg
  Plot,[0,1],[0,1],XStyle=1+4,YStyle=1+4,/NoData  ;change the background
EndIf

;;--
If is_png_eps eq 2 Then Begin
thick   = 2.5
xthick  = 2.5
ythick  = 2.5
charthick = 2.5
charsize  = 1.5
EndIf
If is_png_eps eq 1 Then Begin
thick   = 2.2
xthick  = 1.5
ythick  = 1.5
charthick = 1.5
charsize  = 1.5
EndIf



Step3_2:
;===========================
;Step3_2:

;;--
position_img  = [0.05,0.05,0.95,0.95]
num_subimgs_x = 1
num_subimgs_y = 1
panel_str_arr = StrArr(num_subimgs_y)
panel_str_arr = ['a']
dx_subimg   = (position_img[2]-position_img[0])/num_subimgs_x
dy_subimg   = (position_img[3]-position_img[1])/num_subimgs_y
;;--
x_margin_left = 0.10
x_margin_right= 0.88
y_margin_bot  = 0.10
y_margin_top  = 0.95

perp_symbol_oct = "170 ;"                           
perp_symbol_str = String(Byte(perp_symbol_oct))  
perp_symbol_str = '{!9' + perp_symbol_str + '!X}'


freq_vect = 1./period_vect  ;from high to low frequencies
xplot_vect= freq_vect
;;--
yplot_vect_v1 = Frac_alf_fw_vect_plot 
title_v1 = TexToIDL('FW Alfven')
yplot_vect_v2 = Frac_alf_bw_vect_plot
title_v2 = TexToIDL('BW Alfven')
yplot_vect_v3 = Frac_fast_fw_vect_plot
title_v3 = TexToIDL('FW Fast')
yplot_vect_v4  = Frac_fast_bw_vect_plot
title_v4 = TexToIDL('BW Fast')
yplot_vect_v5  = Frac_slow_fw_vect_plot
title_v5 = TexToIDL('FW slow')
yplot_vect_v6  = Frac_slow_bw_vect_plot
title_v6 = TexToIDL('BW slow')

 
;;--  
lg_xplot_vect = Alog10(xplot_vect)
lg_xrange = [Min(lg_xplot_vect), Max(lg_xplot_vect)]
lg_xrange = [lg_xrange[0]-0.1*(lg_xrange[1]-lg_xrange[0]), lg_xrange[1]+0.1*(lg_xrange[1]-lg_xrange[0])]
xrange = 10.^lg_xrange

yrange_min = min([yplot_vect_v1,yplot_vect_v2,yplot_vect_v3, $
                  yplot_vect_v4,yplot_vect_v5,yplot_vect_v6])
yrange_max = max([yplot_vect_v1,yplot_vect_v2,yplot_vect_v3, $
                  yplot_vect_v4,yplot_vect_v5,yplot_vect_v6])                
lg_yrange = [Alog10(yrange_min), Alog10(yrange_max)]     
lg_xrange = [lg_xrange[0]-0.1*(lg_xrange[1]-lg_xrange[0]), lg_xrange[1]+0.1*(lg_xrange[1]-lg_xrange[0])] 
yrange = 10.^lg_yrange   
yrange[1] = 1


xtitle  = 'freq [Hz]'
title  = TexToIDL('MHD waves Composition')

;;--
i_subimg_x = 0
i_subimg_y = 0
win_position= [position_img[0]+dx_subimg*i_subimg_x+x_margin_left*dx_subimg,$
        position_img[1]+dy_subimg*i_subimg_y+y_margin_bot*dy_subimg,$
        position_img[0]+dx_subimg*i_subimg_x+x_margin_right*dx_subimg,$
        position_img[1]+dy_subimg*i_subimg_y+y_margin_top*dy_subimg]
position_subplot  = win_position
position_SubImg   = position_SubPlot

;;--
Plot, xplot_vect, yplot_vect_v1, XRange=xrange, YRange=yrange, Position=position_subplot, $
  XStyle=1, YStyle=1, XTitle=xtitle, YTitle=ytitle, Title=title, Color=color_black, /NoErase, $
  XLog=1, YLog=0, $
  Thick=thick, XThick=xthick, YThick=ythick, CharThick=charthick, CharSize=charsize
Plots, xplot_vect,yplot_vect_v1,Color=color_green,Thick=thick
Plots, xplot_vect,yplot_vect_v2,Color=color_green,Thick=thick,Linestyle=2
Plots, xplot_vect,yplot_vect_v3,Color=color_blue,Thick=thick
Plots, xplot_vect,yplot_vect_v4,Color=color_blue,Thick=thick,Linestyle=2
Plots, xplot_vect,yplot_vect_v5,Color=color_red,Thick=thick
Plots, xplot_vect,yplot_vect_v6,Color=color_red,Thick=thick,Linestyle=2
;;--
dpos = 0.13
tpos = 0.05
xpos_tmp = position_subplot[2]+0.01
ypos_tmp_v1 = position_subplot[3]-tpos
ypos_tmp_v2 = position_subplot[3]-tpos-dpos*1
ypos_tmp_v3 = position_subplot[3]-tpos-dpos*2
ypos_tmp_v4 = position_subplot[3]-tpos-dpos*3
ypos_tmp_v5 = position_subplot[3]-tpos-dpos*4
ypos_tmp_v6 = position_subplot[3]-tpos-dpos*5
XYOuts,xpos_tmp,ypos_tmp_v1,title_v1,color=color_green,charsize=charsize,/Normal
XYOuts,xpos_tmp,ypos_tmp_v2,title_v2,color=color_green,charsize=charsize,/Normal
XYOuts,xpos_tmp,ypos_tmp_v3,title_v3,color=color_blue,charsize=charsize,/Normal
XYOuts,xpos_tmp,ypos_tmp_v4,title_v4,color=color_blue,charsize=charsize,/Normal
XYOuts,xpos_tmp,ypos_tmp_v5,title_v5,color=color_red,charsize=charsize,/Normal
XYOuts,xpos_tmp,ypos_tmp_v6,title_v6,color=color_red,charsize=charsize,/Normal
;;--
dpos = 0.13
tpos = 0.11
xpos_beg = position_subplot[2]+0.01
xpos_end = position_subplot[2]+0.10
ypos_tmp_v1 = position_subplot[3]-tpos
ypos_tmp_v2 = position_subplot[3]-tpos-dpos*1
ypos_tmp_v3 = position_subplot[3]-tpos-dpos*2
ypos_tmp_v4 = position_subplot[3]-tpos-dpos*3
ypos_tmp_v5 = position_subplot[3]-tpos-dpos*4
ypos_tmp_v6 = position_subplot[3]-tpos-dpos*5
plots,[xpos_beg,xpos_end],[ypos_tmp_v1,ypos_tmp_v1],Color=color_green,thick=thick,/Normal
plots,[xpos_beg,xpos_end],[ypos_tmp_v2,ypos_tmp_v2],Color=color_green,thick=thick,/Normal,Linestyle=2
plots,[xpos_beg,xpos_end],[ypos_tmp_v3,ypos_tmp_v3],Color=color_blue,thick=thick,/Normal
plots,[xpos_beg,xpos_end],[ypos_tmp_v4,ypos_tmp_v4],Color=color_blue,thick=thick,/Normal,Linestyle=2
plots,[xpos_beg,xpos_end],[ypos_tmp_v5,ypos_tmp_v5],Color=color_red,thick=thick,/Normal
plots,[xpos_beg,xpos_end],[ypos_tmp_v6,ypos_tmp_v6],Color=color_red,thick=thick,/Normal,Linestyle=2
;;--
AnnotStr_tmp  = 'got from "TV_Composition_alf_fast_slow_fw_bw_subroutine.pro"'
AnnotStr_arr  = [AnnotStr_tmp]
AnnotStr_tmp  = 'calling program: '+calling_program
AnnotStr_arr  = [AnnotStr_arr, AnnotStr_tmp]
AnnotStr_tmp  = TimeRange_str_TV
AnnotStr_arr  = [AnnotStr_arr, AnnotStr_tmp]
num_strings     = N_Elements(AnnotStr_arr)
For i_str=0,num_strings-1 Do Begin
  position_v1   = [position_img[0],position_img[1]/(num_strings+2)*(i_str+1)]
  CharSize    = 0.95
  XYOuts,position_v1[0],position_v1[1],AnnotStr_arr(i_str),/Normal,$
      CharSize=charsize,color=color_black,Font=-1
EndFor

;;--
If is_png_eps eq 1 Then Begin
image_tvrd  = TVRD(true=1)
Write_PNG, FileName_v3, image_tvrd; tvrd(/true), r,g,b
EndIf Else Begin
If is_png_eps eq 2 Then Begin
;;;--
Device,/Close
EndIf
EndElse

End_Program:
Return
End