function gel_box_summary(summary,path_string,file_string)

prompt = {'Enter bottom band label:','Enter top band label:'};

dlgtitle = 'Band Labels';
dims = [1 65];
definput = {'Bottom Band','Top Band'};

labels = inputdlg(prompt,dlgtitle,dims,definput);

[m,n] = size(summary);

path_string = regexprep(path_string,'excel_files','output_figures');
output_file_string = fullfile(path_string,file_string);
output_file_string = erase(output_file_string,'.xlsx');
fig_title = erase(file_string,'.xlsx');
fig_title = regexprep(fig_title,'_',' ');
output_file_string_b = sprintf('%s_boxes',output_file_string);
output_file_string_r = sprintf('%s_r_squared',output_file_string);
output_file_string_f = sprintf('%s_fits.xlsx',output_file_string);
output_file_string_f = strrep(output_file_string_f,'output_figures','excel_files');
output_file_string_i = sprintf('%s_insets.xlsx',output_file_string);
output_file_string_i = strrep(output_file_string_i,'output_figures','excel_files');

total_figures = n*3;
fig_handles = 1:total_figures;
im_handles = 1:3:total_figures;
fit_handles = 2:3:total_figures;
back_fit_handles = 3:3:total_figures;

no_of_panels_wide = 6;
no_of_panels_high = (total_figures + ...
    mod(total_figures,no_of_panels_wide))/no_of_panels_wide;


left_pads = 0.55 * ones(1,no_of_panels_wide);
left_pads([1 2 3 5 6]) = 0.1;
right_pads = 0.15 * ones(1,no_of_panels_wide);
right_pads(6) = 0.9;

sp = initialise_publication_quality_figure( ...
    'no_of_panels_wide', no_of_panels_wide, ...
    'no_of_panels_high', no_of_panels_high, ...
    'top_margin', 0.2, ...
    'bottom_margin', 0, ...
    'right_margin', 1, ...
    'individual_padding', 1, ...
    'left_pads', repmat(left_pads,[1 no_of_panels_high]), ...
    'right_pads', repmat(right_pads,[1 no_of_panels_high]), ...
    'axes_padding_top', 0.2, ...
    'axes_padding_bottom',0.5, ...
    'panel_label_font_size', 0, ...
    'figure_handle',19);

numel(sp)
for i = 1 : length(im_handles)
    h = subplot(sp(im_handles(i)));
    colormap(h,"gray")
    t1 = sprintf('%s',fig_title);
    t2 = sprintf('Box %i',i);
    title({t1,t2}, 'FontSize',7)
    center_image_with_preserved_aspect_ratio( ...
        summary(i).inset,sp(im_handles(i)));
    
    subplot(sp(fit_handles(i)))
    plot(summary(i).x-(summary(i).x_back)',summary(i).y,'k-');
    hold on
    patch(summary(i).band_1, ...
        summary(i).y,'b','FaceAlpha',0.1);
    patch(summary(i).band_2, ...
        summary(i).y,'y','FaceAlpha',0.1);
    plot(summary(i).x_fit,summary(i).y, ...
        'ro','MarkerSize',1);
    t{i} = sprintf('r^2 = %.3f',summary(i).r_squared);

 
    top_area = (summary(i).top)/(summary(i).top+summary(i).bottom);
    bottom_area = (summary(i).bottom)/(summary(i).top+summary(i).bottom);
    


    subplot(sp(back_fit_handles(i)))
    plot(summary(i).x,summary(i).y,'k-');
    hold on
    bottom = fill(sp(back_fit_handles(i)),summary(i).x_back+summary(i).band_1, ...
        summary(i).y,'b','FaceAlpha',0.1);
    top = fill(sp(back_fit_handles(i)),summary(i).x_back+summary(i).band_2, ...
        summary(i).y,'y','FaceAlpha',0.1);
    plot(summary(i).x_back,summary(i).y, ...
        'mo','MarkerSize',1);
    plot(summary(i).x_fit+summary(i).x_back,summary(i).y, ...
        'ro','MarkerSize',1);
        str_bottom = sprintf('%%%s = %.2f', string(labels{1}),bottom_area);
    str_top = sprintf('%%%s = %.2f', string(labels{2}),top_area);
    leg_labels = {str_top,str_bottom};

    legendflex([top,bottom], leg_labels, ...
        'xscale',0.15, ...
        'anchor',{'nw','nw'}, ...
        'buffer',[-20 0], ...
        'padding',[1 1 2], ...
        'FontSize',6, ...
        'text_y_padding', -2);
end

for i = 1:length(fit_handles)
improve_axes('axis_handle',sp(fit_handles(i)),...
    'x_tick_decimal_places',0, ...
    'y_tick_decimal_places',0,...
    'y_axis_label',{'Pixels'},'y_label_offset',-0.3,...
    'x_label_offset',-0.45,...
    'tick_font_size',9,...
    'label_font_size',9,...
    'x_axis_label',{'Background','Corr. Opt. Density'},...
    'y_ticks',[1 length(summary(i).x)],...
    'x_ticks',[min(summary(i).x-(summary(i).x_back)') ...
    max(summary(i).x-(summary(i).x_back)')],'title',t{i}, ...
    'title_font_size', 9)
end

for i = 1:length(back_fit_handles)
improve_axes('axis_handle',sp(back_fit_handles(i)),...
    'x_tick_decimal_places',0, ...
    'y_tick_decimal_places',0,...
    'y_axis_off',1,...
    'x_label_offset',-0.35,...
    'tick_font_size',9,...
    'label_font_size',9,...
    'x_axis_label',{'Opt. Density'},...
    'x_ticks',[0 max(summary(i).x)],...
    'gui_scale_factor',0)
end


figure_export('output_file_string', output_file_string_b,'output_type', 'png');

p = initialise_publication_quality_figure( ...
    'no_of_panels_wide', 1, ...
    'no_of_panels_high', 1, ...
    'top_margin', 0.2, ...
    'bottom_margin', 0, ...
    'right_margin', 1, ...
    'individual_padding', 1, ...
    'left_pads', repmat(0.35,[1 1]), ...
    'right_pads', repmat(0.15,[1 1]), ...
    'axes_padding_top', 0.2, ...
    'axes_padding_bottom',0.5, ...
    'panel_label_font_size', 0, ...
    'figure_handle',20,'x_to_y_axes_ratio',5);

figure(20)
cla
for i = 1 : length(im_handles)
    i_name = sprintf('box_%i',i);
    insets.(i_name) = summary(i).inset;
    plot(i, summary(i).r_squared,'bo')
    hold on
    xlabel('Box No')
    ylabel('r squared')

end

hold on
plot(1:length(im_handles),0.9*ones(1,length(im_handles)),':r', ...
    'LineWidth',2)
xlim([0.9 n*1.1])
xticks([1:n])
ylim([0 1.05])

improve_axes('axis_handle',p,'x_axis_label', 'Box No',...
    'y_axis_label','r^2', 'x_tick_decimal_places',0, ...
    'y_tick_decimal_places',0,...
    'x_ticks',[1:n],...
    'gui_scale_factor',0.05,...
    'x_label_offset',-0.35,...
    'y_label_offset',-0.05)

figure_export('output_file_string', output_file_string_r,'output_type', 'png');



summary = rmfield(summary,'top');
summary = rmfield(summary,'bottom');
summary = rmfield(summary,'r_squared');
summary = rmfield(summary,'inset');

names = fieldnames(summary);
for j = 1 : length(summary)
    for i = 1 : numel(names)

        [row,col] = size(summary(j).(names{i}));

        if row == 1 && col ~= 1
            summary(j).(names{i}) = (summary(j).(names{i}))';
        end
    end
    sheet = sprintf('box_%i',j);
    writetable(struct2table(summary(j)),output_file_string_f,'Sheet',sheet)
    writematrix(insets.(sheet),output_file_string_i,'Sheet',sheet)
end



end