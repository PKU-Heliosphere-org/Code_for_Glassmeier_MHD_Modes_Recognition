Pro get_Mode_Composition_based_On_Mode_Recognition_Method_For_MHD_Waves, $
  JulDay_vect_wavelet, period_vect, $
  Bt_RTN_vect_cal, Np_RTN_vect_cal, Wp_RTN_vect_cal, $
  wavlet_Bx_arr, wavlet_By_arr, wavlet_Bz_arr, $
  wavlet_Vx_arr, wavlet_Vy_arr, wavlet_Vz_arr, $
  wavlet_Np_arr, $
  Bxyz_LBG_RTN_arr=Bxyz_LBG_RTN_arr, $
  k_over_omega_arr=k_over_omega_arr, $
  Frac_alf_fw_arr=Frac_alf_fw_arr, Frac_alf_bw_arr=Frac_alf_bw_arr, $
  Frac_fast_fw_arr=Frac_fast_fw_arr, Frac_fast_bw_arr=Frac_fast_bw_arr, $
  Frac_slow_fw_arr=Frac_slow_fw_arr, Frac_slow_bw_arr=Frac_slow_bw_arr
  

Step1:
;====================
mu0 = 4*!pi*1.e-7  ;unit: H/m
n0 = Mean(Np_RTN_vect_cal,/NaN) ;unit: cm^-3
TeV_RTN_vect_cal = get_ion_Temperature(Wp_RTN_vect_cal)
TMK_RTN_vect_cal = TeV_RTN_vect_cal* 11604. * 1.e-6
Bt_G_RTN_vect_cal = Bt_RTN_vect_cal * 1.e-5
VA = get_Alfven_velocity(Mean(Np_RTN_vect_cal,/NaN),Mean(Bt_G_RTN_vect_cal,/NaN)) ;unit: km/s
Cs = get_Ion_Soundvelocity(Mean(TMK_RTN_vect_cal,/NaN),1.0)  ;unit: km/s
;beta = get_plasma_beta(Mean(Np_RTN_vect_cal,/NaN), Mean(TeV_RTN_vect_cal,/NaN), Mean(Bt_G_RTN_vect_cal,/NaN))
beta = Cs^2.0/VA^2.0

Step2:
;====================
;;--
num_times = N_Elements(JulDay_vect_wavelet)
num_periods = N_Elements(period_vect)
;;--
Frac_alf_fw_arr = Fltarr(num_times, num_periods)
Frac_alf_bw_arr = Fltarr(num_times, num_periods)
Frac_fast_fw_arr = Fltarr(num_times, num_periods)
Frac_fast_bw_arr = Fltarr(num_times, num_periods)
Frac_slow_fw_arr = Fltarr(num_times, num_periods)
Frac_slow_bw_arr = Fltarr(num_times, num_periods)


Step3:
;====================
;;--
For i_time=0, num_times-1 Do Begin
  For i_period=0, num_periods-1 Do Begin
    ;;--
    Br = wavlet_Bx_arr[i_time,i_period]
    Bt = wavlet_By_arr[i_time,i_period]
    Bn = wavlet_Bz_arr[i_time,i_period]
    B_rtn_vect = [Br, Bt, Bn] * 21.8 * n0^(-0.5);unit: km/s
    Vr = wavlet_Vx_arr[i_time,i_period]
    Vt = wavlet_Vy_arr[i_time,i_period]
    Vn = wavlet_Vz_arr[i_time,i_period]
    V_rtn_vect = [Vr, Vt, Vn]
    n = wavlet_Np_arr[i_time,i_period]
    ;;--
    k_omega_vect = Reform(k_over_omega_arr[*,i_time,i_period])
    B0_local_vect = Reform(Bxyz_LBG_RTN_arr[*,i_time,i_period])
    eB0_vect = B0_local_vect/Norm(B0_local_vect)
    ex_vect = k_omega_vect/Norm(k_omega_vect)
    ex_vect = ex_vect/Norm(ex_vect)
    ey_vect = Crossp(eB0_vect, ex_vect)
    ey_vect = ey_vect/Norm(ey_vect)
    ey_vect = ey_vect/Norm(ey_vect)
    ez_vect = Crossp(ex_vect, ey_vect)
    ez_vect = ez_vect/Norm(ez_vect)
    ez_vect = ez_vect/Norm(ez_vect)
    theta = Acos(ex_vect ## Transpose(eB0_vect))
    theta = theta[0]
    By = B_rtn_vect ## Transpose(ey_vect)
    Bz = B_rtn_vect ## Transpose(ez_vect)
    Vx = V_rtn_vect ## Transpose(ex_vect)
    Vy = V_rtn_vect ## Transpose(ey_vect)
    Vz = V_rtn_vect ## Transpose(ez_vect)    
    ;;--
    Vf = VA * Sqrt((1+beta)/2+0.5*sqrt(1+beta^2-2*beta*cos(2*theta)))
    Vs = VA * Sqrt((1+beta)/2-0.5*sqrt(1+beta^2-2*beta*cos(2*theta)))
    hf = Sqrt(1+VA^2*beta/Vf^2+VA^2*sin(theta)^2*(Vf^2+VA^2*cos(theta)^2)/(Vf^2-VA^2*cos(theta)^2)^2)
    hs = Sqrt(1+VA^2*beta/Vs^2+VA^2*sin(theta)^2*(Vs^2+VA^2*cos(theta)^2)/(Vs^2-VA^2*cos(theta)^2)^2)
    State_vect = Transpose([Vy,By,Vx,Vz,Bz,n*Cs/n0])/VA
    ;;--
    Eigenvalues_vect = Transpose([+VA*cos(theta),-VA*cos(theta),+Vf,-Vf,+Vs,-Vs])
    S_matrix = State_vect ## Conj(Transpose(State_vect))
    ;;--　
    E_alf_forward = Transpose([-1/sqrt(2),1/sqrt(2),0.0,0.0,0.0,0.0])
    E_alf_backward = Transpose([1/sqrt(2),1/sqrt(2),0.0,0.0,0.0,0.0])
    E_fast_forward = Transpose([0,0,1,-VA^2*sin(theta)*cos(theta)/(Vf^2-VA^2*cos(theta)^2),VA*Vf*sin(theta)/(Vf^2-VA^2*cos(theta)^2),VA*sqrt(beta)/Vf]/hf)
    E_fast_backward = Transpose([0,0,1,-VA^2*sin(theta)*cos(theta)/(Vf^2-VA^2*cos(theta)^2),-VA*Vf*sin(theta)/(Vf^2-VA^2*cos(theta)^2),-VA*sqrt(beta)/Vf]/hf)
    E_slow_forward = Transpose([0,0,1,-VA^2*sin(theta)*cos(theta)/(Vs^2-VA^2*cos(theta)^2),VA*Vs*sin(theta)/(Vs^2-VA^2*cos(theta)^2),VA*sqrt(beta)/Vs]/hs)
    E_slow_backward = Transpose([0,0,1,-VA^2*sin(theta)*cos(theta)/(Vs^2-VA^2*cos(theta)^2),-VA*Vs*sin(theta)/(Vs^2-VA^2*cos(theta)^2),-VA*sqrt(beta)/Vs]/hs)
    ;;--
    Frac_alf_fw = Real_Part(Transpose(E_alf_forward) ## S_matrix ## E_alf_forward)
    Frac_alf_bw = Real_Part(Transpose(E_alf_backward) ## S_matrix ## E_alf_backward)
    Frac_fast_fw = Real_Part(Transpose(E_fast_forward) ## S_matrix ## E_fast_forward)
    Frac_fast_bw = Real_Part(Transpose(E_fast_backward) ## S_matrix ## E_fast_backward)
    Frac_slow_fw = Real_Part(Transpose(E_slow_forward) ## S_matrix ## E_slow_forward)
    Frac_slow_bw = Real_Part(Transpose(E_slow_backward) ## S_matrix ## E_slow_backward)
    Normalization = sqrt(Abs(Frac_alf_fw)^2+Abs(Frac_alf_bw)^2+Abs(Frac_fast_fw)^2+$
      Abs(Frac_fast_bw)^2+Abs(Frac_slow_fw)^2+Abs(Frac_slow_bw)^2)
;    Normalization = Abs(Frac_alf_fw)+Abs(Frac_alf_bw)+Abs(Frac_fast_fw)+Abs(Frac_fast_bw)+Abs(Frac_slow_fw)+Abs(Frac_slow_bw)
    Frac_alf_fw_arr[i_time,i_period] = Frac_alf_fw/Normalization
    Frac_alf_bw_arr[i_time,i_period] = Frac_alf_bw/Normalization
    Frac_fast_fw_arr[i_time,i_period] = Frac_fast_fw/Normalization
    Frac_fast_bw_arr[i_time,i_period] = Frac_fast_bw/Normalization
    Frac_slow_fw_arr[i_time,i_period] = Frac_slow_fw/Normalization
    Frac_slow_bw_arr[i_time,i_period] = Frac_slow_bw/Normalization
  Endfor
Endfor

End