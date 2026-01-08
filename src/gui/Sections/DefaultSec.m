classdef DefaultSec
    properties
        parent 
        system System
    end

    methods
        function this = DefaultSec(panel, s)
            this.parent = panel;
            this.system = s;

            g_i = uigridlayout(this.parent, [1 3]);
            g_i.BackgroundColor = [0.12 0.12 0.15];
        end
    end

end