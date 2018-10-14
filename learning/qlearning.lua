--emu:loadrom('galaga.zip')
--require("numlua")
emu.pause()
function append_zeros_to_left(value, length)
  value_str = "" .. value
  while string.len(value_str) < length do
    value_str = "0" .. value_str
  end;

  return value_str
end;

--initialize qtable
print("Initializing table...")
q_table = {}
keys = {}
--generate all possible strings
for pos=8,183,1 do
  pos_str = append_zeros_to_left(pos,3)
  for enemy=0,88888,1 do
    enemy_str = append_zeros_to_left(enemy,5)
    if string.find(enemy_str,"9") == nil then
      for bullet1=0,1,1 do
        for bullet2=0,1,1 do
          final_str= "" .. pos_str .. enemy_str .. bullet1 .. bullet2
          table.insert(keys, final_str)
          print(final_str)
        end;
      end;
    end;
  end;
end;

--for each key, add key to table, initialize all table actions to zero
for k=1,#keys,1 do
  q_table[keys[k]] = {0,0,0,0,0}
end;

print("Table initialized.")

--decay epsilon value to increase learing over time
function decay_epsilon(prog_count, e)
  if prog_count % 60 then
    e = e - 0.1
  end;
  if e > 0 then
    return e;
  else
    return 0;
  end;
end;

function choose_action(current_state,q_table,epsilon)
  if math.random() < epsilon then
    return math.random(0,5);
  end;
  
  --choose action that grants max q given current_state
  max_q = math.max(q_table[current_state][0],q_table[current_state][1],q_table[current_state][2],q_table[current_state][3],q_table[current_state][4],q_table[current_state][5]);
  next_action_list = {}
  for i=0,5,1 do
    if q_table[current_state][i] == max_q then
      table.insert(next_action_list,i)
    end;
  end;
  
  if #next_action_list == 1 then
    return next_action_list[1];
  else
    rand_choice = math.random(1,#next_action_list)
    return next_action_list[rand_choice]; 
  end;
end;

--get reward based on previous score and new current score
function get_reward(score, past_score)
  if past_score - score == 0 then
    return -1;
  elseif past_score - score > 0 then
    return 0;
  end;
end;

--get state from memory bytes
function get_state()
  pos = memory.readbyte(515)
  erow_1 = memory.readbyte(1024) + memory.readbyte(1025) + memory.readbyte(1026) + memory.readbyte(1027) + memory.readbyte(1028) + memory.readbyte(1029) + memory.readbyte(1030) + memory.readbyte(1031) + memory.readbyte(1032)
  erow_2 = memory.readbyte(1040) + memory.readbyte(1041) + memory.readbyte(1042) + memory.readbyte(1043) + memory.readbyte(1044) + memory.readbyte(1045) + memory.readbyte(1046) + memory.readbyte(1047) + memory.readbyte(1048)
  erow_3 = memory.readbyte(1056) + memory.readbyte(1057) + memory.readbyte(1058) + memory.readbyte(1059) + memory.readbyte(1060) + memory.readbyte(1061) + memory.readbyte(1062) + memory.readbyte(1063) + memory.readbyte(1064)
  erow_4 = memory.readbyte(1072) + memory.readbyte(1073) + memory.readbyte(1074) + memory.readbyte(1075) + memory.readbyte(1076) + memory.readbyte(1077) + memory.readbyte(1078) + memory.readbyte(1079) + memory.readbyte(1080)
  erow_5 = memory.readbyte(1088) + memory.readbyte(1089) + memory.readbyte(1090) + memory.readbyte(1091) + memory.readbyte(1092) + memory.readbyte(1093) + memory.readbyte(1094) + memory.readbyte(1095) + memory.readbyte(1096)
  b1 = memory.readbyte(736) / 128
  b2 = memory.readbyte(744) / 128
  return "" .. pos .. erow_1 .. erow_2 .. erow_3 .. erow_4 .. erow_5 .. b1 .. b2;
end;

--update q_table based on current q values, reward, discount rate, learning rate
function update_table(prev_state,curr_state,a, r,dr, lr)
  --find maximum q value based on new state
  max_val = math.max(q_table[curr_state][0],q_table[curr_state][1],q_table[curr_state][2],q_table[curr_state][3],q_table[curr_state][4],q_table[curr_state][5])
  q_table[prev_state][a] = q_table[prev_state][a] + lr * (r + dr * max_val - q_table[prev_state][a])
end;

emu.speedmode("turbo")
emu.unpause()

inputTable = joypad.read(1);
framecount = 1
for i= 0,10000,1 do
  savestate.load(savestate.object(10));
  local file = io.open("outputs/qlearning/outputTest_" .. i .. ".csv", "w");
  framecount = 1;
  counter = 0;
  score = 0;
  past_score = 0;
  lives = memory.readbyte(1159);
  state = "0080000000"
  prev_state = "0080000000"
  alpha = 0.1
  gamma = 0.9
  epsilon = 1
  
  --Run Simulation until first death
  while lives >= 2 do
    --set joypad presses
    joypad.set(1, inputTable)

    --decay epsilon
    epsilon = decay_epsilon(counter, epsilon)

    --Update action after 20 frames
    if(framecount % 20 == 0) then
      --reset framecount
      framecount = 1
      
      --update lives
      lives = memory.readbyte(1159);
      
      --update score
      past_score = score;
      score0 = memory.readbyte(224);
      score1 = memory.readbyte(225);
      score2 = memory.readbyte(226);
      score3 = memory.readbyte(227);
      score4 = memory.readbyte(228);
      score5 = memory.readbyte(229);
      score6 = memory.readbyte(230);
      score = score0 * 10^6 + score1 * 10^5 + score2 * 10^4 + score3 * 10^3 + score4 * 10^2 + score5 * 10 + score6;

      --recieve previous reward
      reward = get_reward(score,past_score)
      
      --update state
      prev_state = state
      state = get_state()

      --update q_table
      

      --clear joypad
      for k,v in pairs(inputTable) do
        inputTable[k] = false;
      end;
      
      --choose action
      action_val = choose_action(curr_state, q_table, epsilon)

      --left; no shoot
      if action_val == 0 then
        inputTable['left'] = true;
      --left; shoot
      elseif action_val == 1 then
        inputTable['left'] = true;
        inputTable['A'] = true;
      --right; no shoot
      elseif action_val == 2 then
        inputTable['right'] = true;
      --right; shoot
      elseif action_val == 3 then
        inputTable['right'] = true;
        inputTable['A'] = true;
      --stationary; no shoot
      elseif action_val == 4 then
        inputTable['A'] = false;
      --stationary; shoot
      elseif action_val == 5 then
        inputTable['A'] = true;
      end;
    end;

    --Write output to file
    file:write(counter);
    file:write(",");
    file:write(memXPos);
    file:write(",");
    file:write(score);
    file:write(",");
    file:write(lives);
    file:write("\n");

    --Increase frame count
    framecount = framecount + 1
    
    --Increase program step counter
    counter = counter + 1

    --Advance emulation frame
    emu.frameadvance();
  end;

  file:close();
end;

-- optimize calcs.  don't need to check everything on every frame