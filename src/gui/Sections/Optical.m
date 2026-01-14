classdef Optical < handle
    properties
    end

    methods
        function this = Optical(parent, system)
            % Create grid layout
            g = uigridlayout(parent, [3 1]);
            g.RowHeight = {'fit', 'fit', 'fit'};
            g.Padding = [10 10 10 10];
            
            uicheckbox(g, 'Text', 'pre-distort');
            uicheckbox(g, 'Text', 'chromatic-dispersion');
            uicheckbox(g, 'Text', 'photodiode');
        end
    end

end