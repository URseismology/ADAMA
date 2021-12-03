function [] =  saveFig(fName, saveDir, usePDF, figHandle)
% This function saves an image into PDF and other format
    if usePDF == 1
        saveFile = [saveDir  fName];
        set(figHandle,'Units','Inches');
        pos = get(figHandle,'Position');
        set(figHandle,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        print(figHandle,saveFile,'-dpdf','-r0');
    else
        saveFile = [saveDir  fName];
        set(gcf,'PaperPositionMode','auto');
        print(saveFile,'-dpng','-r0');
    end
        
end