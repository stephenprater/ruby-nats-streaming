require 'stan/client'

sc = STAN::Client.new
opts = { servers: ["nats://127.0.0.1:4222"] }
sc.connect("test-cluster", "client-123", nats: opts)

10.times { sc.publish("foo", "hello again") }

# Subscribe starting with most recently published value
sc.subscribe("foo", start_at: :last_received) do |msg|
  puts "Received a message (start_at: :last_received, seq: #{msg.seq}): #{msg.data}"
end

# Receive all stored values in order
sc.subscribe("foo", deliver_all_available: true) do |msg|
  puts "Received a message (start_at: :deliver_all_available, seq: #{msg.seq}}): #{msg.data}"
end

# Receive messages starting at a specific sequence number
sc.subscribe("foo", start_at: :sequence, sequence: 3) do |msg|
  puts "Received a message (start_at: :sequence, seq: #{msg.seq}): #{msg.data}"
end

# Subscribe starting at a specific time by giving a unix timestamp
# with an optional nanoseconds fraction
sc.subscribe("foo", start_at: :time, time: Time.now.to_f - 3600) do |msg|
  puts "Received a message (start_at: :time, seq: #{msg.seq}): #{msg.data}"
end

sc.close
