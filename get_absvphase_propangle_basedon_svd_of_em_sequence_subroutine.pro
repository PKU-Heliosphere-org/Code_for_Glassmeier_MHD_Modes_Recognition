
Pro get_AbsVphase_PropAngle_BasedOn_SVD_of_EM_sequence_subroutine, $
	time_vect, period_vect, $ ;input
	Vphase_arr, Bxyz_LBG_GSE_arr, $ ;input
	AbsVphase_arr, theta_Vph_b0_arr ;output


num_times = N_Elements(time_vect)
num_periods = N_Elements(period_vect)

;;--
AbsVphase_arr  = Fltarr(num_times,num_periods)
theta_Vph_b0_arr  = Fltarr(num_times,num_periods)


For i_time=0,num_times-1 Do Begin
For i_scale=0,num_periods-1 Do Begin
  Vphase_vect = Reform(Vphase_arr[*,i_time,i_scale])
  b0_vect   = Reform(Bxyz_LBG_GSE_arr[*,i_time,i_scale])
  AbsVphase = Norm(Vphase_vect)
  unit_Vp_vect = Vphase_vect / AbsVphase
  b0_vect   = b0_vect/Norm(b0_vect)

  AbsVphase_arr[i_time,i_scale] = AbsVphase
;d  theta_Vph_b0_arr(i_time,i_scale) = ACos(Abs(unit_Vp_vect ## Transpose(b0_vect))) * 180/!pi
  theta_Vph_b0_arr(i_time,i_scale) = ACos((unit_Vp_vect ## Transpose(b0_vect))) * 180/!pi
EndFor
EndFor


Return
End_Program:
End

