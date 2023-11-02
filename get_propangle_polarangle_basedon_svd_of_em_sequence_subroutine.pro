
Pro get_PropAngle_PolarAngle_BasedOn_SVD_of_EM_Sequence_subroutine, $
	time_vect, period_vect, $
	EigVect_arr, Bxyz_LBG_GSE_arr, $
	theta_k_db_arr, theta_k_b0_arr, theta_db_b0_arr


i_eigenval_min  = 0
i_eigenval_mid  = 1
i_eigenval_max  = 2

num_times = N_Elements(time_vect)
num_periods = N_Elements(period_vect)

;;--
theta_k_db_arr  = Fltarr(num_times,num_periods)
theta_k_b0_arr  = Fltarr(num_times,num_periods)
theta_db_b0_arr = Fltarr(num_times,num_periods)

;For i_theta=0,4-1 Do Begin
For i_time=0,num_times-1 Do Begin
For i_scale=0,num_periods-1 Do Begin
  k_db_vect = Reform(EigVect_arr[*,i_eigenval_min,i_time,i_scale])  ;k_Zp
  e_db_vect = Reform(EigVect_arr[*,i_eigenval_max,i_time,i_scale])  ;e_Zp
  b0_vect   = Reform(Bxyz_LBG_GSE_arr[*,i_time,i_scale])
  k_db_vect = k_db_vect/Norm(k_db_vect)
  e_db_vect = e_db_vect/Norm(e_db_vect)
  b0_vect   = b0_vect/Norm(b0_vect)

  theta_k_db_arr[i_time,i_scale]  = ACos(Abs(k_db_vect ## Transpose(e_db_vect))) * 180/!pi  ;angle between k_Zp with e_Zm
  theta_k_b0_arr[i_time,i_scale]  = ACos(Abs(k_db_vect ## Transpose(b0_vect))) * 180/!pi
  theta_db_b0_arr[i_time,i_scale] = ACos(Abs(e_db_vect ## Transpose(b0_vect))) * 180/!pi
  
;  theta_k_db_arr[i_time,i_scale]  = ACos(k_db_vect ## Transpose(e_db_vect)) * 180/!pi  ;angle between k_Zp with e_Zm
;  theta_k_b0_arr[i_time,i_scale]  = ACos(k_db_vect ## Transpose(b0_vect)) * 180/!pi
;  theta_db_b0_arr[i_time,i_scale] = ACos(e_db_vect ## Transpose(b0_vect)) * 180/!pi

EndFor
EndFor


Return
End_Program:
End



