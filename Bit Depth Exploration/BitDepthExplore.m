function [QuantizedImage] = BitDepthExplore(Input, BD)

%If image is double: Takes double image as input, quantizes, then truncates to target bitdepth
%After truncation, converts back to double

%If image is uintXX, truncates to BD.  If BD > XX, does nothing

    if isa(Input,'double')
        if BD<64+1
            QuantizedImage = uint64(Input.*(2.^64-1));
            QuantizedImage = bitshift(QuantizedImage,-(64-BD));
            QuantizedImage = bitshift(QuantizedImage,(64-BD));
            QuantizedImage = double(QuantizedImage);
            QuantizedImage = QuantizedImage./(2.^64-1);
        else
            QuantizedImage = Input;
            warning('BD out of range for double! Data not modified')
        end
    elseif isa(Input,'uint8')
        if BD<8+1
            QuantizedImage = bitshift(Input,-(8-BD));
            QuantizedImage = bitshift(QuantizedImage,(8-BD));
        else
            QuantizedImage = Input;
            warning('BD out of range for uint8! Data not modified')
        end
    elseif isa(Input,'uint16')
        if BD<16+1
            QuantizedImage = bitshift(Input,-(16-BD));
            QuantizedImage = bitshift(QuantizedImage,(16-BD));
        else
            QuantizedImage = Input;
            warning('BD out of range for uint16! Data not modified')
        end
    elseif isa(Input,'uint32')
        if BD<32+1
            QuantizedImage = bitshift(Input,-(32-BD));
            QuantizedImage = bitshift(QuantizedImage,(32-BD));
        else
            QuantizedImage = Input;
            warning('BD out of range for uint32! Data not modified')
        end
    elseif isa(Input,'uint64')
        if BD<64+1
            QuantizedImage = bitshift(Input,-(64-BD));
            QuantizedImage = bitshift(QuantizedImage,(64-BD));
        else
            QuantizedImage = Input;
            warning('BD out of range for uint64! Data not modified')
        end
    else
        QuantizedImage = Input;
        warning(strcat('Data class', 32, class(Input) , 32,'not supported!'))
        warning('Data not modified')
    end
end
