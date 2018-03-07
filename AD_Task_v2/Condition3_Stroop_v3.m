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
PsychImaging('PrepareConfiguration')
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
arrayX = x - x1/2;
arrayY = y - y1/2;
wordX = arrayX(1,2);
wordY = arrayY(1,2);
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
        DrawFormattedText(window, 'Respond to the location of \n the incongruently colored word \n with the up and down arrow keys \n and the location of the box \n with the A and F keys during \n the break following the trial \n after they were presented in', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    if block == 2
        numTrials = 5;
        c3v3dm1 = nan(8,numTrials);
        Screen('TextSize', window, 40);
        Screen('TextFont', window, 'Courier');
        DrawFormattedText(window, 'Press any key to start', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    if block == 3
        numTrials = 5;
        c3v3dm2 = nan(8,numTrials);
        Screen('TextSize', window, 40);
        Screen('TextFont', window, 'Courier');
        DrawFormattedText(window, 'Take a break \n Press any key to continue', 'center', 'center', white);
        Screen('Flip',window);
        KbStrokeWait;
    end
    boxNumCorrect = 0;
    wordsNumCorrect = 0;
    for trial = 1:numTrials+1
        %%draw the words
        line1 = 'Red';
        line2 = 'Blue';
        line3 = 'Red';
        line4 = 'Blue';
        %%assign random color to the words
        rng('shuffle')
        textColor=randi([0,100],1,4);
        color1=textColor(1,1);
        color2=textColor(1,2);
        color3=textColor(1,3);
        color4=textColor(1,4);
        colorTarget=min(textColor);
        if color1 == colorTarget
            color1=[0 0 1];
            color2=[0 0 1];
            color3=[1 0 0];
            color4=[0 0 1];
            colorRec1=0;
            colorRec2=0;
            colorRec3=1;
            colorRec4=0;
        elseif color2 == colorTarget
            color1=[1 0 0];
            color2=[1 0 0];
            color3=[1 0 0];
            color4=[0 0 1];
            colorRec1=1;
            colorRec2=1;
            colorRec3=1;
            colorRec4=0;
        elseif color3 == colorTarget
            color1=[1 0 0];
            color2=[0 0 1];
            color3=[0 0 1];
            color4=[0 0 1];
            colorRec1=1;
            colorRec2=0;
            colorRec3=0;
            colorRec4=0;
        elseif color4 == colorTarget
            color1=[1 0 0];
            color2=[0 0 1];
            color3=[1 0 0];
            color4=[1 0 0];
            colorRec1=1;
            colorRec2=0;
            colorRec3=1;
            colorRec4=1;
        end
        Screen('TextSize', window, 35);
        Screen('DrawText',window,line1,xCenter - 1.5*wordX,yCenter + wordY,color1);
        Screen('DrawText',window,line2,xCenter + .5*wordX,yCenter + wordY,color2);
        Screen('DrawText',window,line3,xCenter - 1.5*wordX,yCenter - wordY,color3);
        Screen('DrawText',window,line4,xCenter + .5*wordX,yCenter - wordY,color4);
        %%assign random location to the box
        rng('shuffle');
        boxLctn = randi([0,100]);
        xLctn = max(arrayX);
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
        
        %%flip to window for 1 second, have participant resond during
        %%rest
        
        Screen('Flip',window);
        WaitSecs(1);
        
        %%give first trial instructions
        if trial==1
            Screen('TextSize', window, 35);
            DrawFormattedText(window,'Press any key to continue' ,'center','center', white);
        end
        Screen('Flip',window);
        %%record response
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
        %%rest after response
        if respMade == 2
            Screen('FillRect',window,grey);
            Screen('Flip',window);
            WaitSecs(1);
        end        
        %%record practice responses
        if practice == 0
            if trial < numTrials+1
                practDataMat(1,trial) = colorRec1;
                practDataMat(2,trial) = colorRec2;
                practDataMat(3,trial) = colorRec3;
                practDataMat(4,trial) = colorRec4;
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
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(2,trial-1) == 1
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,2) == 2
                    if practDataMat(1,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(2,trial-1) == 1
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,1) == 4
                    if practDataMat(3,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 1
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Incorrect', 'center',screenYpixels * .333, white);
                    end
                end
                if resp(1,2) == 4
                    if practDataMat(3,trial-1) == 0
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 1
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Correct', 'center',screenYpixels * .333, white);
                        wordsNumCorrect = wordsNumCorrect+1;
                    else
                        Screen('TextSize', window, 50);
                        Screen('TextFont', window, 'Courier');
                        DrawFormattedText(window, 'Words - Incorrect', 'center',screenYpixels * .333, white);
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
                    if c3v3dm1(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 1
                    if c3v3dm1(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 3
                    if c3v3dm1(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 3
                    if c3v3dm1(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 2
                    if c3v3dm1(1,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,2) == 2
                    if c3v3dm1(1,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,1) == 4
                    if c3v3dm1(2,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,2) == 4
                    if c3v3dm1(2,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
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
                    if c3v3dm2(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 1
                    if c3v3dm2(5,trial-1) < 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 3
                    if c3v3dm2(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,2) == 3
                    if c3v3dm2(5,trial-1) >= 50
                        boxNumCorrect = boxNumCorrect+1;
                    end
                end
                if resp(1,1) == 2
                    if c3v3dm2(1,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,2) == 2
                    if c3v3dm2(1,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(3,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,1) == 4
                    if c3v3dm2(2,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
                if resp(1,2) == 4
                    if c3v3dm2(2,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    elseif practDataMat(4,trial-1) == 0
                        wordsNumCorrect = wordsNumCorrect+1;
                    end
                end
            end
        end
        %%record block responses
        if block == 2
            if trial < numTrials+1
                c3v3dm1(1,trial) = colorRec1;
                c3v3dm1(2,trial) = colorRec2;
                c3v3dm1(3,trial) = colorRec3;
                c3v3dm1(4,trial) = colorRec4;
                c3v3dm1(5,trial) = boxCenX;
            elseif trial == numTrials+1
                c3v3dm1(1,trial) = 0;
                c3v3dm1(2,trial) = 0;
                c3v3dm1(3,trial) = 0;
                c3v3dm1(4,trial) = 0;
                c3v3dm1(5,trial) = 0;
            end
            if trial > 1
                c3v3dm1(6,trial-1) = resp(1,1);
                c3v3dm1(7,trial-1) = resp(1,2);
                c3v3dm1(8,trial-1) = rt;
            end
        end
        if block == 3
            if trial < numTrials+1
                c3v3dm2(1,trial) = colorRec1;
                c3v3dm2(2,trial) = colorRec2;
                c3v3dm2(3,trial) = colorRec3;
                c3v3dm2(4,trial) = colorRec4;
                c3v3dm2(5,trial) = boxCenX;
            elseif trial == numTrials+1
                c3v3dm2(1,trial) = 0;
                c3v3dm2(2,trial) = 0;
                c3v3dm2(3,trial) = 0;
                c3v3dm2(4,trial) = 0;
                c3v3dm2(5,trial) = 0;
            end
            if trial > 1
                c3v3dm2(6,trial-1) = resp(1,1);
                c3v3dm2(7,trial-1) = resp(1,2);
                c3v3dm2(8,trial-1) = rt;
            end
        end
        correctResponses(1,block) = boxNumCorrect;
        correctResponses(2,block) = wordsNumCorrect;
    end
practice = 1;
boxPercent = correctResponses(1,block)/numTrials;
wordsPercent = correctResponses(2,block)/numTrials;
line1 = 'Dots - ';
line3 = 'Box - ';
line2 = wordsPercent;
line4 = boxPercent;
Screen('TextSize', window, 35);
Screen('DrawText',window,line1,xCenter - 1.5*wordX,yCenter + wordY,white);
Screen('DrawText',window,line2,xCenter + .5*wordX,yCenter + wordY,white);
Screen('DrawText',window,line3,xCenter - 1.5*wordX,yCenter - wordY,white);
Screen('DrawText',window,line4,xCenter + .5*wordX,yCenter - wordY,white);        
Screen('Flip',window);
KbStrokeWait;
end
KbStrokeWait
ListenChar(2);
sca
%%response key
%botLctn 540= resp 1
%botLctn 740 = resp 3
%array(u->d) 0 0 1 0 or 1 1 1 0 = resp 2
%array(u->d) 1 0 0 0 or 1 0 1 1 = resp 4