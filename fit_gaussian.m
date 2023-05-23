function [y_bands, y_fit]= fit_gaussian(x,y,y_back,no_of_bands)

peaks=find_peaks('x',x, ...
    'y',y, ...
    'min_rel_delta_y',0.025, ...
    'min_x_index_spacing',5);

figure(9)
cla
plot(y,x)
hold on
plot(y(peaks.max_indices),peaks.max_indices,'o')
% findpeaks(y)
% plot(peaks)
if numel(peaks.max_indices) ~= no_of_bands
%     warn_text = sprintf('The number of peaks is not equaled to number of bands.\nThe number of bands is adjusted to the number of peaks');
%     fprintf(warn_text)
    no_of_bands = 2;
end
target = y';

target = target - y_back;
[max_value,max_index]=max(target);

par = zeros(no_of_bands,3);

half_distance=(0.1*length(x));
alfa_estimate = -log(0.5)/(half_distance^2);
skew = 1;
peaks.max_indices = []
peaks.max_indices(1) = round(0.5*length(x))
peaks.max_indices(2) = round(0.6*length(x))
for m = 1:no_of_bands
par(m,1) = target(peaks.max_indices(m));
par(m,2) = alfa_estimate;
par(m,3) = peaks.max_indices(m);
par(m,4) = skew;
end

par = reshape(par.',1,[]);

j = 1;
e = [];

[p_result,fval,exitflag,output] = fminsearch(@profile_error, par, []);

    function trial_e = profile_error(par)

        [y_bands,y_fit] = calculate_profile(x,par);

        e(j) = 0;

        for i  = 1 : numel(target)
            e(j) = e(j) + (y_fit(i) - target(i))^2;
        end

        trial_e = e(end);
        
        if any(par<0)
            trial_e = 10^6;
        end

        j = j + 1;
    end
    function [y_bands,y_fit] = calculate_profile(x,par)       
        y_fit = 0;
        k = 1;
        for i = 1 : no_of_bands
            par_dum(i,:) = par(k:k+3);
            k = k + numel(par_dum(i,:));
       end

        for i = 1 : no_of_bands

            offset=zeros(1,length(x));
            offset((x-par_dum(i,3))>0)=par_dum(i,4)*(x((x-par_dum(i,3))>0)-par_dum(i,3));
            y_bands(i,:) = par_dum(i,1)*exp(-par_dum(i,2)*(((x-par_dum(i,3))+offset).^2));
            y_fit = y_fit + y_bands(i,:);
        end

    end
end