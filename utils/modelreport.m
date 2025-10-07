function m=modelreport(m)

%% Create model report

    disp('Generating Model Report...');

	x = report.new('Model report: model.model');
    
    %-- model files
    x.modelfile('QPM Model','model.model', m);
    x.pagebreak();
    
    %-- steady state table
    endovars = get(m,'xlist');
    desc = get(m, 'desc');
    mtrx = cell(length(endovars), 3);
        
    i_tblelem=0;
    for j = 1:length(endovars)
        if isstationary(m, endovars{j})==1
            i_tblelem=i_tblelem+1;
            mtrx{i_tblelem,1} = endovars{j};
            mtrx{i_tblelem,2} = desc.(endovars{j});
            mtrx{i_tblelem,3} = round(real(m.(endovars{j})),7);
        end
    end
    
    mtrx_out = cell(i_tblelem, 3);
    mtrx_out=mtrx(1:i_tblelem,:);
    
    x.array('Steady state', mtrx_out,...
            'heading',{'Variable','Description','Value'},...
            'long',true,'format','%0.3g');
    
    %-- publish
    x.publish('results/Model.pdf','display',false);
    
end