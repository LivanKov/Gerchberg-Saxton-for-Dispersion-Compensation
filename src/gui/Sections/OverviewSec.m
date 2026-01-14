classdef OverviewSec < handle
    properties
    end

    methods
        function this = OverviewSec(parent, system)
            % Create grid layout
            g = uigridlayout(parent, [1 1]);
            g.Padding = [10 10 10 10];
            
            % Get the path to the media folder
            projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
            imagePath = fullfile(projectRoot, 'media', 'System.png');
            
            % Create axes and display image
            ax = uiaxes(g);
            ax.Toolbar.Visible = 'off';
            ax.XTick = [];
            ax.YTick = [];
            
            if isfile(imagePath)
                img = imread(imagePath);
                imshow(img, 'Parent', ax);
            else
                title(ax, 'Image not found');
            end
        end
    end

end
