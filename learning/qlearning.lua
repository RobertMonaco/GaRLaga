--emu:loadrom('galaga.zip')
--require("numlua")

inputTable = joypad.read(1);
framecount = 1
for i= 0,10000,1 do
  savestate.load(savestate.object(10));
  continue_sim = true;
  local file = io.open("outputs/qlearning/outputTest_" .. i .. ".csv", "w");
  step_action = 0;
  
  while continue_sim do
    joypad.set(1, inputTable)
    if(framecount % 20 == 0) then
      framecount = 1
      --choose action
      
      input_key = math.random()
      for k,v in pairs(inputTable) do
        inputTable[k] = false;
      end;
      if math.random() <= 0.5 then
        inputTable['A'] = true;
      end;
      if input_key <= 0.33 then
          inputTable['left'] = true;
      else
        if input_key <= 0.66 then
          inputTable['right'] = true;
        end;
      end;
      --print(input_key)
      --print(inputTable)
    end;

    --position is 8 - 183
    memXPos = memory.readbyte(515);
    score0 = memory.readbyte(224);
    score1 = memory.readbyte(225);
    score2 = memory.readbyte(226);
    score3 = memory.readbyte(227);
    score4 = memory.readbyte(228);
    score5 = memory.readbyte(229);
    score6 = memory.readbyte(230);
    lives = memory.readbyte(1159);
    --print(memory.readbyte(340))
    --print(memory.readbyte(341))
    --print(memory.readbyte(342))
    --print(memory.readbyte(343))
    --print(memory.readbyte(344))
    --print(memory.readbyte(345))
    --print(memory.readbyte(346))
    --print(memory.readbyte(347))
    --print(memory.readbyte(348))
    --print(memory.readbyte(349))
  
    score = score0 * 10^6 + score1 * 10^5 + score2 * 10^4 + score3 * 10^3 + score4 * 10^2 + score5 * 10 + score6;
    
    file:write(step_action);
    file:write(",");
    file:write(memXPos);
    file:write(",");
    file:write(score);
    file:write(",");
    file:write(lives);
    file:write("\n");

    framecount = framecount + 1
    step_action = step_action + 1
    emu.frameadvance();

    if lives < 2 or score > 5000 then
      continue_sim = false;
    end;
  end;

  file:close();
end;

-- optimize calcs.  don't need to check everything on every frame