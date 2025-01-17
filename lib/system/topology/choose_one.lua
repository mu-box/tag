-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet

-- each node has one data point associated with it, they never move
return function(data,order,state,id)
  for idx,name in pairs(order) do
    if name == id then
      is_alive = state[name]
      if is_alive then
        return {data[idx]}
      end
    end
  end

  return {}
end
