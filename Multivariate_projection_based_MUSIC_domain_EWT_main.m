clc;
clear all;
close all;
load val.mat;
Fs=128;
L=size(val,2);
x=val((1:32),(1:25*Fs));
for i=1:32
    x(i,:)=x(i,:)/max(abs(x(i,:)));
end
xf=x;
Combined = (sum(xf))/sqrt(32);
nfft=128;
subplot(311)
plot(Combined);
xlim([0 3200])
%%%%%%%music based PSD estimation%%%%%%%%
number_sinosuids=80;
[S,fo] = pmusic(Combined,number_sinosuids,nfft,Fs);
S=S/max(abs(S));
[pk, lk]=findpeaks(S);
for i=1:length(lk)-1
lk1(i)=(lk(i)+lk(i+1))/2;
end
boundaries=lk1(1:15); %%%considering 15 boundary points, one can vary based on the applications%%%%%
subplot(312)
plot(fo,S);
xlim([0 64])
%%%%%EWT filter bank%%%%%%%
boundaries=(boundaries*(2*pi))/Fs;
ff=fft(Combined);
% We build the corresponding filter bank
mfb=EWT_Meyer_FilterBank(boundaries,length(ff));
Bound=1;
xxx=(linspace(0,1,round(length(mfb{1,1}))))*Fs;
subplot(313)
for i=1:size(mfb)
plot(xxx,mfb{i,1})
hold on
end
xlim([0 64])
ylim([0 2])
title('Multivariate Projection based Music EWT filter bank')

for ch=1:size(x,1)
    all_ch_modes(ch,:,:)=mode_eval_each_channel(x(ch,:),mfb);
end

%%%%individual channel mode evaluation%%%%%%%%%
ch1=x(1,:);
ft=fft(ch1);
for k=1:length(mfb)
    ewt{k}=real(ifft(conj(mfb{k})'.*ft));
     modes(k,:)=ewt{k};    
end
np=15;
for i=1:np
    subplot(3,5,i);
    plot(modes(i,:));
    grid on
end