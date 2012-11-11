class User < Model
  def _act
    f = Frig.new("frig", 1)
    f.open
    f.put_elephant
    f.put_elephant
    f.close
  end
end

class Frig < Model
  def initialize(name = "", pos = 0)
    super
    @m_stm.def_edge('$', 'door is opened', 'open')
    @m_stm.def_edge('door is opened', 'door is closed', 'close')
    @m_stm.def_edge('door is opened', 'door is opened w/ elephant', 'put_elephant')
    @m_stm.def_edge('door is opened w/ elephant', 'door is closed w/ elephant', 'close')
  end
end