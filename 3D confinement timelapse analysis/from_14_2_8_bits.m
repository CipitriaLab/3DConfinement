function I_8bits = from_14_2_8_bits(I)
%% Convert the images from czi 14 bits to 8 bits integer - works with 2D or 3D dataset
% figure;
% histogram(I);
% xlim([0 2^14]);
%
%% This function transform a 14 bits images from czi to a normal 8 bits image
if nargin ~= 1
    error('You did not put any argument');
end
tmp_maxi = max(max(I));
if tmp_maxi > 2^14 && tmp_maxi < 2^32
    % Then the original image was not 14 bits and was in 16 bits
    org_bit = 16;
    msg = 'The current image was supposed to be 14 bits, but turned out to be 16  bits';
    disp(msg);
elseif tmp_maxi > 2^16 && tmp_maxi < 2^32
    % Then the original image was not 16 bits and was in 32 bits
    org_bit = 32;
    msg = 'The current image was supposed to be 14 bits, but turned out to be 32 bits';
    disp(msg);
elseif isa(I,'uint8')
    % then no need to do anything.
    I_8bits = I;
    return;
else
    org_bit = 14;
end
I_norm = double(I)./2^(org_bit);
I_8bits = uint8(I_norm.*255);

% figure;
% histogram(I_norm.*255);
% xlim([0 2^8]);


end