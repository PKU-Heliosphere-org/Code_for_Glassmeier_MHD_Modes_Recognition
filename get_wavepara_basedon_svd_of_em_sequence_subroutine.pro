Pro get_WavePara_BasedOn_SVD_of_EM_Sequence_subroutine, $
      wavlet_Bx_arr, wavlet_By_arr, wavlet_Bz_arr, $
      wavlet_Ex_arr, wavlet_Ey_arr, wavlet_Ez_arr, $
      time_vect, period_vect, $
      Bxyz_LBG_GSE_arr, $  ;input
      EigVal_arr, EigVect_arr, $  ;output
      EigVal_EM_arr, EigVect_EM_arr, $  ;output
      PlanarityPolarization_arr=PlanPolar_arr, $
      EplipticPolarization_arr=ElipPolar_arr, $
      SensePolarization_arr=SensePolar_arr, $
      SensePolar_E_arr=SensePolar_E_arr, $
      DegreePolarization_arr=DegreePolar_arr, $
;d      RefraIndex_arr=RefraIndex_arr
      k_over_omega_arr=k_over_omega_arr	      ;unit: s/m
      
    
Step1:  
;Step1:
;=====================

;;--
num_times   = N_Elements(time_vect)
num_periods = N_Elements(period_vect) 
 
RefraIndex_arr = Fltarr(3, num_times, num_periods) ;refraction index vector = k_vect * c / omega (no need of c for SI-unit)
;(Vsw_x+Vphase_x, Vsw_y+Vphase_y, Vsw_z+Vphase_z) = (omega/kx, omega/ky, omega/kz)
;Faraday equation: curl_E=-pB/pt (SI-unit), curl_E=-1/c*pB/pt (Gaussian-unit) 

;c_speed = ;no need of c for Faraday equation in SI-unit
c_speed = 1.0

epsilon_arr = Fltarr(3,3,3) ;https://en.wikipedia.org/wiki/Levi-Civita_symbol
epsilon_arr(0,1,2) = 1
epsilon_arr(1,2,0) = 1
epsilon_arr(2,0,1) = 1
epsilon_arr(2,1,0) = -1
epsilon_arr(0,2,1) = -1
epsilon_arr(1,0,2) = -1

I_upcase = 3 ;B_i
J_upcase = 3 ;n_j
K_upcase = 3 ;E_k
L_upcase = 6 ;Z_l

;;--estimate refraction index vector according to Faraday's law (in Gaussian-unit) (see Santolik, RadioScience, 2003)
;;--estimate k_over_omega vector according to Faraday's law (in SI-unit)
k_over_omega_arr = Fltarr(3,num_times,num_periods)
;;--added by XYZhu (2020-03-26)
EigVal_EM_arr = Fltarr(3,num_times,num_periods)
EigVect_EM_arr = Fltarr(3,3,num_times,num_periods)
For i_time=0,num_times-1 Do Begin
For i_scale=0,num_periods-1 Do Begin

  Bx_wavlet=wavlet_Bx_arr(i_time,i_scale) & By_wavlet=wavlet_By_arr(i_time,i_scale) & Bz_wavlet=wavlet_Bz_arr(i_time,i_scale)
  Ex_wavlet=wavlet_Ex_arr(i_time,i_scale) & Ey_wavlet=wavlet_Ey_arr(i_time,i_scale) & Ez_wavlet=wavlet_Ez_arr(i_time,i_scale)
  Z_vect = [c_speed*Bx_wavlet, c_speed*By_wavlet, c_speed*Bz_wavlet, Ex_wavlet, Ey_wavlet, Ez_wavlet]
  Q_arr = Z_vect # ConJ(Z_vect)

  A_complex_arr = Complexarr(3, I_upcase*L_upcase)
  B_complex_vect= Complexarr(1, I_upcase*L_upcase)
  For i_lc=0,I_upcase-1 Do Begin ;_lc means _lower case
  For l_lc=0,L_upcase-1 Do Begin
    il_lc = i_lc*L_upcase + l_lc
    For j_lc=0,J_upcase-1 Do Begin
      For k_lc=0,K_upcase-1 Do Begin
        A_complex_arr(j_lc,il_lc) = A_complex_arr(j_lc,il_lc) + $
					epsilon_arr(i_lc,j_lc,k_lc) * Q_arr(3+k_lc,l_lc)
      EndFor
    EndFor
    B_complex_vect(il_lc) = Q_arr(i_lc,l_lc)
  EndFor
  EndFor


  A_real_arr = Fltarr(3, I_upcase*L_upcase*2)
  B_real_vect= Fltarr(1, I_upcase*L_upcase*2)
  A_real_arr(*,0:I_upcase*L_upcase-1) = Real_Part(A_complex_arr)
  A_real_arr(*,I_upcase*L_upcase:I_upcase*L_upcase*2-1) = Imaginary(A_complex_arr)
  B_real_vect(0:I_upcase*L_upcase-1) = Real_Part(B_complex_vect)
  B_real_vect(I_upcase*L_upcase:I_upcase*L_upcase*2-1) = Imaginary(B_complex_vect)
  
  LA_SVD, A_real_arr, W_EM, U_EM, V_EM
  ascend_order = Sort(W_EM)
  EigVal_EM_arr[*,i_time,i_scale] = W_EM[ascend_order]
  For i=0,2 Do Begin
    EigVect_EM_arr[*,i,i_time,i_scale] = Reform(V_EM[ascend_order[i],*])
  Endfor
  W_EM_v2=Fltarr(3,3) & W_EM_v2(0,0)=W_EM(0) & W_EM_v2(1,1)=W_EM(1) & W_EM_v2(2,2)=W_EM(2)
  W_EM = W_EM_v2
  ;wrong: W_EM(36,3), U_EM(3,3), V_EM(3,3), A_real_arr(36,3)
  ;U_EM(3,36) is a matrix 36x3 with three orthonormal columns
  ;W_EM(3,3) is a diagonal matrix 3x3 of singular values
  ;V_EM(3,3) is a matrix 3x3 with orthonormal columns
  inv_W_EM = Fltarr(3,3)
  inv_W_EM(0,0)=1./W_EM(0,0) & inv_W_EM(1,1)=1./W_EM(1,1) & inv_W_EM(2,2)=1./W_EM(2,2)
;a  n_vect = Transpose(V_EM) # IMSL_Inv(W_EM) # Transpose(U_EM) # B_real_vect
  n_vect = Transpose(V_EM) # (inv_W_EM # (U_EM # Transpose(B_real_vect)))
;  n_vect = V_EM ## inv_W_EM ## Transpose(U_EM) ## B_real_vect
	;n_vect(3,1)=V_EM'(3,3) # inv(W_EM)(3,3) # U_EM'(3,36) # B_real_vect(36,1)
	;in principle, n=kc/omega, refraction index

  k_over_omega_arr(*,i_time,i_scale) = n_vect * (1.e-9/1.e-3) ;unit: s/m 
  
EndFor
EndFor


Step2: 
;Step2:
;=====================

EigVect_arr  = Fltarr(3, 3, num_times, num_periods)  ;eigvect_time_scale_arr(*,i_eigen,i_time,i_scale)=Reform(V_v2)
EigVal_arr   = Fltarr(3, num_times, num_periods) ;ascending order
PlanPolar_arr = Fltarr(num_times,num_periods)
ElipPolar_arr = Fltarr(num_times,num_periods)
SensePolar_arr= Fltarr(num_times,num_periods)
DegreePolar_arr = Fltarr(num_times,num_periods)
SensePolar_E_arr= Fltarr(num_times,num_periods)

;;--
For i_time=0,num_times-1 Do Begin
For i_scale=0,num_periods-1 Do Begin
  A_arr = Fltarr(3,6)
  A_arr(0,0)  = Real_Part(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_Bx_arr(i_time,i_scale)))  ;R_S11   A_ij=A(j,i)=Real(Bi*ConJ(Bj))
  A_arr(1,0)  = Real_Part(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_By_arr(i_time,i_scale)))  ;R_S12
  A_arr(2,0)  = Real_Part(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale)))  ;R_S13
  A_arr(0,1)  = Real_Part(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_By_arr(i_time,i_scale)))  ;R_S12
  A_arr(1,1)  = Real_Part(wavlet_By_arr(i_time,i_scale)*ConJ(wavlet_By_arr(i_time,i_scale)))  ;R_S22
  A_arr(2,1)  = Real_Part(wavlet_By_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale)))  ;R_S23
  A_arr(0,2)  = Real_Part(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale)))  ;R_S13
  A_arr(1,2)  = Real_Part(wavlet_By_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale)))  ;R_S23
  A_arr(2,2)  = Real_Part(wavlet_Bz_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale)))  ;R_S33
  A_arr(0,3)  = 0.0
  A_arr(1,3)  = -Imaginary(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_By_arr(i_time,i_scale))) ;-I_S12   A_ij=A(j,i)=-Imag(Bi*ConJ(Bj))
  A_arr(2,3)  = -Imaginary(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale))) ;-I_S13
  A_arr(0,4)  = +Imaginary(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_By_arr(i_time,i_scale))) ;+I_S12
  A_arr(1,4)  = 0.0
  A_arr(2,4)  = -Imaginary(wavlet_By_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale))) ;-I_S23
  A_arr(0,5)  = +Imaginary(wavlet_Bx_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale))) ;+I_S13
  A_arr(1,5)  = +Imaginary(wavlet_By_arr(i_time,i_scale)*ConJ(wavlet_Bz_arr(i_time,i_scale))) ;+I_S23
  A_arr(2,5)  = 0.0

  ;;;---
  SVDC, A_arr, W, U, V
  ascend_order  = Sort(W)
  W_v2  = W(ascend_order)
  V_v2  = Fltarr((Size(V))[1],(Size(V))[2]) ;3x3
  For i=0,2 Do Begin
    V_v2(i,*) = V(ascend_order(i),*)
  EndFor  
  ;;;---
  For i=0,2 Do Begin
    EigVal_arr(i,i_time,i_scale)     = W_v2(i)
    EigVect_arr(*,i,i_time,i_scale)  = Reform(V_v2(i,*)) 
  EndFor
  ;;;---
  PlanPolar_arr(i_time,i_scale) = 1 - Sqrt(W_v2(0)/W_v2(2))
  ElipPolar_arr(i_time,i_scale) = W_v2(1) / W_v2(2)
  ;;;---calculate the sense of polarity in the plane perpendicular to B0, value above 3 or below -3 indicates high confidence level
  Bxyz_LBG_GSE_vect = Reform(Bxyz_LBG_GSE_arr(*,i_time,i_scale))
  unit_B0_vect  = Bxyz_LBG_GSE_vect / Norm(Bxyz_LBG_GSE_vect)
  unit_x_GSE_vect = [1.,0.,0.]
  unit_x_FAC_vect = CrossP(unit_B0_vect,unit_x_GSE_vect)
  unit_x_FAC_vect = unit_x_FAC_vect / Norm(unit_x_FAC_vect)
  unit_y_FAC_vect = CrossP(unit_B0_vect, unit_x_FAC_vect)
  unit_y_FAC_vect = unit_y_FAC_vect / Norm(unit_y_FAC_vect)
  unit_z_FAC_vect = unit_B0_vect
  wavlet_Bx_FAC_tmp = wavlet_Bx_arr(i_time,i_scale)*unit_x_FAC_vect(0) + $
                      wavlet_By_arr(i_time,i_scale)*unit_x_FAC_vect(1) + $
                      wavlet_Bz_arr(i_time,i_scale)*unit_x_FAC_vect(2)
  wavlet_By_FAC_tmp = wavlet_Bx_arr(i_time,i_scale)*unit_y_FAC_vect(0) + $
                      wavlet_By_arr(i_time,i_scale)*unit_y_FAC_vect(1) + $
                      wavlet_Bz_arr(i_time,i_scale)*unit_y_FAC_vect(2)
  wavlet_Bz_FAC_tmp = wavlet_Bx_arr(i_time,i_scale)*unit_z_FAC_vect(0) + $
                      wavlet_By_arr(i_time,i_scale)*unit_z_FAC_vect(1) + $
                      wavlet_Bz_arr(i_time,i_scale)*unit_z_FAC_vect(2)                      
  Sxx_FAC_tmp = wavlet_Bx_FAC_tmp * ConJ(wavlet_Bx_FAC_tmp)
  Sxy_FAC_tmp = wavlet_Bx_FAC_tmp * ConJ(wavlet_By_FAC_tmp)
  Syy_FAC_tmp = wavlet_By_FAC_tmp * ConJ(wavlet_By_FAC_tmp)
  Szz_FAC_tmp = wavlet_Bz_FAC_tmp * ConJ(wavlet_Bz_FAC_tmp)
  I_Sxy_tmp = Imaginary(Sxy_FAC_tmp)
  M         = 1.
  sigma_I_Sxy_tmp = Sqrt(Sxx_FAC_tmp*Syy_FAC_tmp - Real_Part(Sxy_FAC_tmp)^2 + Imaginary(Sxy_FAC_tmp)^2) / $
                    Sqrt(2*M)
  SensePolar_arr(i_time,i_scale)  = I_Sxy_tmp / sigma_I_Sxy_tmp
  SensePolar_arr(i_time,i_scale)  = -2*I_Sxy_tmp / (Sxx_FAC_tmp+Syy_FAC_tmp)
  ;;;---presence of a single plane wave will be tested by an estimator of the degree of polarization 
  DegreePolar_arr(i_time,i_scale) = W_v2(2) / (W_v2(0)+W_v2(1)+W_v2(2))
  
  ;;;---get 'SensePolar_E_arr'
  wavlet_Ex_FAC_tmp = wavlet_Ex_arr(i_time,i_scale)*unit_x_FAC_vect(0) + $
                        wavlet_Ey_arr(i_time,i_scale)*unit_x_FAC_vect(1) + $
                        wavlet_Ez_arr(i_time,i_scale)*unit_x_FAC_vect(2)
  wavlet_Ey_FAC_tmp = wavlet_Ex_arr(i_time,i_scale)*unit_y_FAC_vect(0) + $
                        wavlet_Ey_arr(i_time,i_scale)*unit_y_FAC_vect(1) + $
                        wavlet_Ez_arr(i_time,i_scale)*unit_y_FAC_vect(2)
  wavlet_Ez_FAC_tmp = wavlet_Ex_arr(i_time,i_scale)*unit_z_FAC_vect(0) + $
                        wavlet_Ey_arr(i_time,i_scale)*unit_z_FAC_vect(1) + $
                        wavlet_Ez_arr(i_time,i_scale)*unit_z_FAC_vect(2)                                              
  Sxx_E_FAC_tmp = wavlet_Ex_FAC_tmp * ConJ(wavlet_Ex_FAC_tmp)
  Sxy_E_FAC_tmp = wavlet_Ex_FAC_tmp * ConJ(wavlet_Ey_FAC_tmp)
  Syy_E_FAC_tmp = wavlet_Ey_FAC_tmp * ConJ(wavlet_Ey_FAC_tmp)
  Szz_E_FAC_tmp = wavlet_Ez_FAC_tmp * ConJ(wavlet_Ez_FAC_tmp)
  I_Sxy_E_tmp = Imaginary(Sxy_E_FAC_tmp)
  SensePolar_E_arr(i_time,i_scale)  = -2*I_Sxy_E_tmp / (Sxx_E_FAC_tmp+Syy_E_FAC_tmp)

  
EndFor
EndFor


Return

End  
                    
  
  
  

  
  
