require 'rails_helper'

RSpec.describe Robot, :type => :model do
 
  context "Factories" do 
    #pending "add some examples to (or delete) #{__FILE__}"
  end

  context "#valid_and_heavier_weapon?" do 
    before(:all) do 
      @robot    = Robot.new # damage: 6
      @gun      = FactoryGirl.create(:gun)
      
      @gun_i    = @gun.robot_weapons.build 
      @gun_i.health.current   = 1
      @gun_i.health.maximum   = 1
      
      # @damage_t = @robot.damage    # 6
      # @damage_g = @gun_i.damage    # 5
    end
    
    it "should return true if gun is undamaged and has heavier damage" do 
      expect(@robot.valid_and_heavier_weapon?(@gun_i.damage - 1, @gun_i)).to be true
    end

    it "should return false if gun is undamaged but has not a heavier damage" do 
      expect(@robot.valid_and_heavier_weapon?(@gun_i.damage + 1, @gun_i)).to be false
    end

    it "should return same if gun is damaged - w/heavier damage" do 
      # @gun_i.health.current = 0
      @gun_i.play_dead
      expect(@robot.valid_and_heavier_weapon?(@gun_i.damage - 1, @gun_i)).to be false
    end

    it "should return same if gun is damaged - w/lower damage" do 
      # @gun_i.health.current = 0
      @gun_i.play_dead
      expect(@robot.valid_and_heavier_weapon?(@gun_i.damage + 1, @gun_i)).to be false
    end
     
  end
  context "#calculate_damage" do 
    it "should return a number" do 
      # stub valid_and_heavier_weapon?
      robot = FactoryGirl.create(:robot)
      # robot.unstub
      robot.stub(:valid_and_heavier_weapon?)
      expect(robot.calculate_damage).to be > 0 
      # should be a number ... in the future might accept 0
    end

    it "should use valid_and_heavier_weapon? method when it has at least one weapon" do 
      # mock valid_and_heavier_weapon?
      robot = FactoryGirl.create(:robot)
      robot.should_receive(:valid_and_heavier_weapon?)
      expect(robot.calculate_damage).to be > 0 
    end

    it "should use valid_and_heavier_weapon? method when it has at least one weapon" do 
      # mock valid_and_heavier_weapon?
      robot = FactoryGirl.create(:unarmed_robot)
      robot.should_not_receive(:valid_and_heavier_weapon?)
      expect(robot.calculate_damage).to be > 0 
    end

    it "should return a number" do 
      robot = FactoryGirl.create(:robot)
      expect(robot.calculate_damage).to be > 0 
    end

    context "should return a higher number if possible" do 
      it "#should be at least this value" do 
        # currently is the highest one
        robot = FactoryGirl.create(:robot)
        expect(robot.calculate_damage).to be >= robot.damage
      end

      it "#should be equal if weapon is worse than the machines one" do 
        robot = FactoryGirl.create(:robot_with_bad_weapon)
        expect(robot.calculate_damage).to be robot.damage
      end

      it "#should be higher if weapon is better than the machines one" do 
        robot = FactoryGirl.create(:robot_with_slightly_better_weapon)
        expect(robot.calculate_damage).to be > robot.damage     
      end

    end
  end

  context "#alive?" do 
    let(:wall_e) { Robot.new }
    it "should return true if healthy" do 
      wall_e.should_receive(:remaining_health).and_return(1)
      expect(wall_e.alive?).to be true
    end

    it "should return false if not healthy" do 
      wall_e.should_receive(:remaining_health).and_return(0)
      expect(wall_e.alive?).to be false
    end
  end
  context "#recharges" do 
    it "should recharge when it attacks" do
      r1 = FactoryGirl.create(:damaged_t_x)
      r2 = FactoryGirl.create(:t_1000)
      # begin
        health = r1.remaining_health
        ContestSimulator.attack r1, r2
        expect(r1.remaining_health).to be > health
        # ContestSimulator.get_result r1, r2
        # rescue Exception => e
        #   puts "Error: #{e} - #{e.to_s}"
        # end
    end
    it "should not recharge if full" do
      r1 = FactoryGirl.create(:t_x)
      r2 = FactoryGirl.create(:t_1000)
      # begin
        health = r1.remaining_health
        ContestSimulator.attack r1, r2
        expect(r1.remaining_health).to be  health
        # ContestSimulator.get_result r1, r2
        # rescue Exception => e
        #   puts "Error: #{e} - #{e.to_s}"
        # end
    end
  end

  context "knap-sack" do
    it "should kill if possible" do
      r1 = FactoryGirl.create(:mega_bazuka_robot)
      r2 = FactoryGirl.create(:unarmed_robot)
      ContestSimulator.attack r1,r2
      expect(r2.remaining_health).to be 0
    end
    it "should use the least deadliest weapon if it can kill" do 
      r1 = FactoryGirl.create(:mega_bazuka_robot)
      r2 = FactoryGirl.create(:unarmed_robot)
      r2.health.current = 10
      ContestSimulator.attack r1,r2
      puts r2.remaining_health
      expect(r2.remaining_health).to be > 10 - r1.weapons.last.damage
    end
  end

  context "attack speed" do
    it "should have an attack speed" do
    r1 = FactoryGirl.create(:slow_robot)
    expect(r1.attack_speed).to be >= 0
    end
    it "should not be negative" do
      r1 = FactoryGirl.create(:slow_robot)
      r1.attack_speed = -5
      r1.save!
    expect(r1.attack_speed).to be >= 0
    end
    it "should not attack if the counter is not 0" do 
      r1 = FactoryGirl.create(:slow_robot)
      r2 = FactoryGirl.create(:unarmed_robot)
      health = r2.remaining_health
      expect(r2.remaining_health).to be health
    end
  end

  context "freeze" do
    it "should freeze the enemy" do
      r1 = FactoryGirl.create(:ice_man)
      r2 = FactoryGirl.create(:unarmed_robot) 
      ContestSimulator.attack r1,r2
      expect(r2.is_frozen).to be true     
    end
    it "should only freeze the enemy if the weapon freezes" do 
      r1 = FactoryGirl.create(:mega_bazuka_robot)
      r2 = FactoryGirl.create(:unarmed_robot) 
      ContestSimulator.attack r1,r2
      expect(r2.is_frozen).to be false
    end
  end


end
