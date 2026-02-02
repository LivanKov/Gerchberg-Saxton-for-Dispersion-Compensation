% The main window, containing the core of the visual application
% TODOs: 
%   Input overview
%   Noise overview
%   Receiver
%   Output overview

% Display Signalleistung???
classdef MainView < handle
    methods
        function this = MainView()
            clc;close all; 
            s = System;
            f = uifigure('Name','ComViewUI');
            f.Position(3:4) = [600 600];
            f.Resize = "off";
            g = uigridlayout(f,[1 1]);
            g.Padding = [0 0 0 0];
            tabs = uitabgroup(g);
            in_sec = uitab(tabs,'Title','Input');
            n_sec = uitab(tabs,'Title','Noise');
            out_sec = uitab(tabs,'Title','Output');
            sample_sec = uitab(tabs,'Title','Sample');
            settings = uitab(tabs, 'Title', 'Settings');
            overview_sec = uitab(tabs,'Title','Overview');

            
            % Input section
            InputSec(in_sec, s);
    
            % Noise section
            NoiseSec(n_sec, s);
            
            % Output section
            OutputSec(out_sec, s);
            
            % Sample section
            SampleSec(sample_sec, s);

            % Settings section
            Settings(settings, s);

            OverviewSec(overview_sec, s);

        end
    end
end