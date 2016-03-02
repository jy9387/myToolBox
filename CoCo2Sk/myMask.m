function [ ] = myMask( anns, I )
    n=length(anns); if(n==0), return; end
    if( any(isfield(anns,{'segmentation','bbox'})) )
        if(~isfield(anns,'iscrowd')), [anns(:).iscrowd]=deal(0); end
        if(~isfield(anns,'segmentation')), return; end
        close; figure(1);
        set(1, 'position', [0 0 size(I, 1) size(I, 2)]);
        I2 = zeros(size(I,1),size(I,2)); imshow(I2);
        S={anns.segmentation}; hs=zeros(10000,1); k=0; hold on;
        pFill={'LineWidth',1};
        for i=1:n
          if(anns(i).iscrowd), C=[.01 .65 .40]; else C=rand(1,3); end
          if(isstruct(S{i})), M=double(MaskApi.decode(S{i})); k=k+1;
            hs(k)=imagesc(cat(3,M*C(1),M*C(2),M*C(3)),'Alphadata',M*.5);
          else for j=1:length(S{i}), P=S{i}{j}+.5; k=k+1;
              hs(k)=fill(P(1:2:end),P(2:2:end),C,pFill{:}); end
          end
        end
        hs=hs(1:k); hold off;
%         F = getframe(1); mask = F.cdata;
    end   
end

