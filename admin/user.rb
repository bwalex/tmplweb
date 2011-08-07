# Proper auth: use session table with expiry time and user id
#              session_id = hash(user_id, expiry_time, random_value)

class User
  attr_accessor :name
  attr_accessor :id
  @name = nil
  @id = nil

  public
  def initialize(id)
    @id = id
    @name = "Jack"
  end

  def self.authenticate(params)
    '391941413jreifjaofje9130'
  end

  def self.check(id)
    if id == '391941413jreifjaofje9130'
      return new(id)
    else
      return nil
    end
  end

end
