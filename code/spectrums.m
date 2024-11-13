function [src,front,back,left_in, left_out,right_in, right_out,total] = spectrums(DFT,TFSF)
% +++ Loop over frequencies and generate plots
    src = -(min([DFT.horiz+1 (TFSF.ny_b-TFSF.ny_a+1)]))*(conj(DFT.src_Ez).*DFT.src_Hy);
    front = (sum(-1*-1*conj((DFT.front_Ez)).*(DFT.front_Hy)));
    back = (sum(-conj((DFT.back_Ez)).*(DFT.back_Hy)));
    left_in = -(sum(-1*conj((DFT.left_Ez)).*(DFT.left_Hx).*(0>(-1*conj((DFT.left_Ez)).*(DFT.left_Hx)))));
    left_out = -(sum(-1*conj((DFT.left_Ez)).*(DFT.left_Hx).*(0<(-1*conj((DFT.left_Ez)).*(DFT.left_Hx)))));
    right_in = (sum(+conj((DFT.right_Ez)).*(DFT.right_Hx).*(0>(+conj((DFT.right_Ez)).*(DFT.right_Hx)))));  
    right_out = (sum(+conj((DFT.right_Ez)).*(DFT.right_Hx).*(0<(+conj((DFT.right_Ez)).*(DFT.right_Hx)))));  
    total = real(front)+real(back)+real(right_in)+real(right_out)-real(left_in)-real(left_out);
    
end 