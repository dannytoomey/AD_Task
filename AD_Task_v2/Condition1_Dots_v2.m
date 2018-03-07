%%respond during the rest after the trial to avoid conflict effects
%%of responding while stimulus is presented

close all;
clearvars;
sca;
PsychDefaultSetup(2);


Screen('Preference', 'SkipSyncTests', 1);  %added for laptop delete later


ListenChar(0);
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
grey = white/2;
black = BlackIndex(screenNumber);
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices('Apple Internal Keyboard / Trackpad');
KbName('UnifyKeyNames');
escape = KbName('ESCAPE');
leftResp = KbName('a');
rightResp = KbName('f');
downResp = KbName('DownArrow');
upResp = KbName('UpArrow');
space = KbName('space');
PsychImaging('PrepareConfiguration');
[window, rect] = PsychImaging('OpenWindow',screenNumber,grey,[]);
[xCenter, yCenter] = RectCenter(rect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
dim = 1;
[x, y] = meshgrid(dim-1:dim, dim-1:dim);
pixelScale = screenYpixels / (dim*2+2);
x = x .*pixelScale;
y = y .*pixelScale;
x1 = x(1,2);
y1 = y(2,1);
dotX = x - x1/2;
dotY = y - y1/2;
yScale = dotY(1,2);
xScale = dotX(1,2);
numDots = numel(dotX);
dotPositionMatrix = [reshape(dotX, 1, numDots); reshape(dotY, 1, numDots)];
dotCenter = [xCenter,yCenter];
%%start block loop
numBlocks = 3;
practice = 0;
correctResponses = nan(2,numBlocks);
for block = 1:numBlocks
    if practice == 0
        numTrials = 5;
        practDataMat = nan(8,numTrials);
        Screen('TextSize', window, 50);
        Screen('TextFont', window, 'Courier');
        DrawFormattedText(window, 'Respond to the location of \n the black dot with the \n up and down arrow keys \n and the location of the box \n with the A and F keys \n during the break following \n the trial after they were presented in', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    if block == 2
        numTrials = 5;
        c1v2dm1 = nan(8,numTrials);
        Screen('TextSize', window, 40);
        Screen('TextFont', window, 'Courier');
        DrawFormattedText(window, 'Press any key to start', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    if block == 3
        numTrials = 5;
        c1v2dm2 = nan(8,numTrials);
        Screen('TextSize', window, 40);
        Screen('TextFont', window, 'Courier');
        DrawFormattedText(window, 'Take a break \n Press any key to continue', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    boxNumCorrect = 0;
    dotsNumCorrect = 0;
    for trial = 1:numTrials+1  
        %%assign random numbers to the dots
        rng('shuffle');
        dotLctn=randi([0,100],1,4);
        dot1=dotLctn(1,1);
        dot2=dotLctn(1,2);
        dot3=dotLctn(1,3);
        dot4=dotLctn(1,4);
        dotTarget=min(dotLctn);
        %%turn numbers into colors (lowest number is white dot)
        if dot1 == dotTarget
           dot1 = 0;
           dot2 = 1;
           dot3 = 1;
           dot4 = 1;
        elseif dot2 == dotTarget
           dot1 = 1;
           dot2 = 0;
           dot3 = 1;
           dot4 = 1;
        elseif dot3 == dotTarget
           dot1 = 1;
           dot2 = 1;
           dot3 = 0;
           dot4 = 1;
        elseif dot4 == dotTarget
           dot1 = 1;
           dot2 = 1;
           dot3 = 1;
           dot4 = 0;
        end
        %%draw the dots
        dotColors = [dot1,dot2,dot3,dot4;dot1,dot2,dot3,dot4;dot1,dot2,dot3,dot4];
        dotSizes = 100;   
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        Screen('DrawDots',window,dotPositionMatrix,dotSizes,dotColors,dotCenter,1);
        %%assign random location to the box
        rng('shuffle');
        boxLctn = randi([0,100]);
        xLctn = max(dotX);
        if boxLctn < 50
            CenX = min(xLctn);
        elseif boxLctn >= 50
            CenX = max(xLctn);
        end
        %%draw the box
        baseRect = [0 0 x1 2*y1];
        boxCenX = xCenter + CenX;
        centeredRect = CenterRectOnPointd(baseRect, boxCenX, yCenter);
        rectColor = [0 0 0];
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        Screen('FrameRect',window,rectColor,centeredRect,1);
        
        %%flip to window for 1 second, have participant respond during
        %%rest
        
        Screen('Flip',window);
        WaitSecs(1);
        
        %%give first trial instructions        
        Screen('FillRect',window,grey);
        if trial==1
            Screen('TextSize', window, 35);
            DrawFormattedText(window,'Press any key to continue' ,'center','center', white);
        end        
        Screen('Flip',window);
        %%record response, count correct responses
        resp=zeros(1,2);
        respMade = 0;        
        %first trial not recorded
        if trial == 1
            KbStrokeWait;
            respMade = 2;
        end    
        if trial > 1
           tStart = GetSecs; 
           while respMade < 2
                [keyIsDown, secs, keyCode, delta] = KbCheck(keyboardIndices);
               if keyIsDown == 1
                   ind = find(keyCode ~=0);
                   if ind == leftResp
                       respMade=respMade+1;
                       resp(respMade)=1;
                   elseif ind == rightResp
                       respMade=respMade+1;
                       resp(respMade)=3;
                   elseif ind == upResp
                       respMade=respMade+1;
                       resp(respMade)=2;
                   elseif ind == downResp
                       respMade=respMade+1;
                       resp(respMade)=4;
                   elseif ind == escape
                       ShowCursor;                        
                       sca;
                       return
                   end
                   KbWait(keyboardIndices,1);
               end
           end
           tEnd = GetSecs;
           rt = tEnd - tStart;
        end    
        %%record practice responses
        if practice == 0
            if trial < numTrials+1
                practDataMat(1,trial) = dot1;
                practDataMat(2,trial) = dot2;
                practDataMat(3,trial) = dot3;
                practDataMat(4,trial) = dot4;
                practDataMat(5,trial) = boxLctn;
            end
            if trial == numTrials+1
                practDataMat(1,trial) = 0;
                practDataMat(2,trial) = 0;
                practDataMat(3,trial) = 0;
                practDataMat(4,trial) = 0;
                practDataMat(5,trial) = 0;
            end
        end
        %%give feedback on practice trials
        if practice == 0
            if trial == 1
                Screen('FillRect',window,grey);
                Screen('Flip',window);
                WaitSecs(0.01);
            end     
            if trial > 1
                if resp(1,1) == 1
                    if practDataMat(5,trial-1) < 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Correct', 'center',screenYpixels * .666, white);
                        boxNumCorrect = boxNumCorrect+1;
                    elseif practDataMat(5,trial-1) >= 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Incorrect', 'center',screenYpixels * .666, white);
                    end
                end
                if resp(1,2) == 1
                    if practDataMat(5,trial-1) < 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Correct', 'center',screenYpixels * .666, white);
                        boxNumCorrect = boxNumCorrect+1;
                    elseif practDataMat(5,trial-1) >= 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Incorrect', 'center',screenYpixels * .666, white);
                    end
                end
                if resp(1,1) == 3
                    if practDataMat(5,trial-1) >= 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Correct', 'center',screenYpixels * .666, white);
                        boxNumCorrect = boxNumCorrect+1;
                    elseif practDataMat(5,trial-1) < 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Incorrect', 'center',screenYpixels * .666, white);
                    end
                end
                if resp(1,2) == 3
                    if practDataMat(5,trial-1) >= 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Correct', 'center',screenYpixels * .666, white);
                        boxNumCorrect = boxNumCorrect+1;
                    elseif practDataMat(5,trial-1) < 50
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Box - Incorrect', 'center',screenYpixels * .666, white);
                    end
                end
                if resp(1,1) == 2
                    if practDataMat(1,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,2) == 2
                    if practDataMat(1,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,1) == 4
                    if practDataMat(2,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,2) == 4
                    if practDataMat(2,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Correct', 'center',screenYpixels * .333, white);
                        dotsNumCorrect = dotsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Dots - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                Screen('Flip',window);
                WaitSecs(2);
            end
        end        
        if block == 2
            if trial == 1
                Screen('FillRect',window,grey);
                Screen('Flip',window);
                WaitSecs(0.01);
            end     
            if trial > 1
                if resp(1,1) == 1
                    if c1v2dm1(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 1
                    if c1v2dm1(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 3
                    if c1v2dm1(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 3
                    if c1v2dm1(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 2
                    if c1v2dm1(1,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,2) == 2
                    if c1v2dm1(1,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,1) == 4
                    if c1v2dm1(2,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,2) == 4
                    if c1v2dm1(2,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
            end
        end
        if block == 3
            if trial == 1
                Screen('FillRect',window,grey);
                Screen('Flip',window);
                WaitSecs(0.01);
            end     
            if trial > 1
                if resp(1,1) == 1
                    if c1v2dm2(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 1
                    if c1v2dm2(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 3
                    if c1v2dm2(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 3
                    if c1v2dm2(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 2
                    if c1v2dm2(1,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,2) == 2
                    if c1v2dm2(1,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,1) == 4
                    if c1v2dm2(2,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
                if resp(1,2) == 4
                    if c1v2dm2(2,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        dotsNumCorrect = dotsNumCorrect+1;
                    end
                end
            end
        end
        %%record block responses
        if block == 2
            if trial < numTrials+1
                c1v2dm1(1,trial) = dot1;
                c1v2dm1(2,trial) = dot2;
                c1v2dm1(3,trial) = dot3;
                c1v2dm1(4,trial) = dot4;
                c1v2dm1(5,trial) = boxCenX;
            elseif trial == numTrials+1
                c1v2dm1(1,trial) = 0;
                c1v2dm1(2,trial) = 0;
                c1v2dm1(3,trial) = 0;
                c1v2dm1(4,trial) = 0;
                c1v2dm1(5,trial) = 0;
            end
            if trial > 1
                c1v2dm1(6,trial-1) = resp(1,1);
                c1v2dm1(7,trial-1) = resp(1,2);
                c1v2dm1(8,trial-1) = rt;
            end
        end
        if block == 3
            if trial < numTrials+1
                c1v2dm2(1,trial) = dot1;
                c1v2dm2(2,trial) = dot2;
                c1v2dm2(3,trial) = dot3;
                c1v2dm2(4,trial) = dot4;
                c1v2dm2(5,trial) = boxCenX;
            elseif trial == numTrials+1
                c1v2dm2(1,trial) = 0;
                c1v2dm2(2,trial) = 0;
                c1v2dm2(3,trial) = 0;
                c1v2dm2(4,trial) = 0;
                c1v2dm2(5,trial) = 0;
            end
            if trial > 1
                c1v2dm2(6,trial-1) = resp(1,1);
                c1v2dm2(7,trial-1) = resp(1,2);
                c1v2dm2(8,trial-1) = rt;
            end
        end
        correctResponses(1,block) = boxNumCorrect;
        correctResponses(2,block) = dotsNumCorrect;
    end
practice = 1;

%%idea - display % correct for each stimulus at the end of each block,
%%maybe break up experiment into more blocks to keep track of participant
%%accuracy 

%%not working - wont't display percent correct. maybe use something other
%%than drawtext

boxPercent = correctResponses(1,block)/numTrials;
dotPercent = correctResponses(2,block)/numTrials;
line1 = 'Dots - ';
line3 = 'Box - ';
line2 = double(dotPercent);
line4 = double(boxPercent);
Screen('TextSize', window, 35);
Screen('DrawText',window,line1,xCenter - 1.5*xScale,yCenter + yScale,white);
Screen('DrawText',window,line2,xCenter + .5*xScale,yCenter + yScale,white);
Screen('DrawText',window,line3,xCenter - 1.5*xScale,yCenter - yScale,white);
Screen('DrawText',window,line4,xCenter + .5*xScale,yCenter - yScale,white);        
Screen('Flip',window);
KbStrokeWait;
end
ListenChar(2);
KbStrokeWait;
sca
%%response key
%botLctn 540 = resp 1
%botLctn 740 = resp 3
%array(u->d) 1 1 0 1 or 0 1 1 1 = resp 2
%array(u->d) 1 0 1 1 or 1 1 1 0 = resp 4