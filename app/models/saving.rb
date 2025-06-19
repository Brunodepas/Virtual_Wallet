class Saving < ActiveRecord::Base
    #Relationships
    belongs_to :account 

    #validates
    validates :goal_amount, numericality:{greater_than: 0, message: "debe ser mayor a cero"}
    validates :current_amount, numericality: {greater_than_or_equal_to: 0}


    def reached_goal?
    current_amount >= goal_amount
    end


end