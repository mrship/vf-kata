# frozen_string_literal: true

require_relative "../lib/event"

RSpec.describe Event do
  class TestHandler
    attr_accessor :recorded

    def call(*arguments)
      self.recorded = arguments
    end
  end


  describe "#subscribe" do
    it "can register callable blocks" do
      expect { subject.subscribe(->(){}) }.not_to raise_error
    end

    it "can register lambdas" do
      expect { subject.subscribe(lambda {}) }.not_to raise_error
    end

    it "can register Procs" do
      expect { subject.subscribe(Proc.new {}) }.not_to raise_error
    end

    it "raises a specific error if called with a non-callable block" do
      expect { subject.subscribe(1) }.to raise_error(Event::NotCallable)
    end
  end

  describe "#broadcast" do
    it "calls a subscribed handler with any arguments" do
      tester = TestHandler.new

      subject.subscribe(tester)
      subject.broadcast(1, 2, 3)

      expect(tester.recorded).to eq([1, 2, 3])
    end

    it "works with different arguments" do
      tester = TestHandler.new

      subject.subscribe(tester)
      subject.broadcast("a")

      expect(tester.recorded).to eq(["a"])
    end

    it "calls all subscribed handlers" do
      tester = TestHandler.new
      other_tester = TestHandler.new
      non_subscribed = TestHandler.new

      subject.subscribe(tester)
      subject.subscribe(other_tester)
      subject.broadcast(1, 2, 3)

      expect(tester.recorded).to eq([1, 2, 3])
      expect(other_tester.recorded).to eq([1, 2, 3])
      expect(non_subscribed.recorded).to be nil
    end

    it "works with multiple broadcasts" do
      tester = TestHandler.new
      other_tester = TestHandler.new

      subject.subscribe(tester)
      subject.subscribe(other_tester)
      subject.broadcast(1, 2, 3)

      expect(tester.recorded).to eq([1, 2, 3])
      expect(other_tester.recorded).to eq([1, 2, 3])

      subject.broadcast({ called: true })

      expect(tester.recorded).to eq([{ called: true }])
      expect(other_tester.recorded).to eq([{ called: true }])
    end
  end

  describe "#unsubscribe" do
    it "unsubscribes any registered handlers" do
      tester = TestHandler.new

      subject.subscribe(tester)
      subject.broadcast({ called: true })
      subject.unsubscribe(tester)
      subject.broadcast({ called: false })

      expect(tester.recorded).to eq([{ called: true }])
    end

    it "ignores any non-subscribed handlers" do
      tester = TestHandler.new
      other_tester = TestHandler.new

      subject.subscribe(tester)
      subject.broadcast({ called: true })
      subject.unsubscribe(other_tester)
      subject.broadcast({ called: false })

      expect(tester.recorded).to eq([{ called: false }])
      expect(other_tester.recorded).to be nil
    end

    it "supports subscribing and unsubscribing and re-subscribing" do
      tester = TestHandler.new

      subject.subscribe(tester)
      subject.broadcast({ called: true })
      subject.unsubscribe(tester)
      subject.broadcast({ called: false })

      expect(tester.recorded).to eq([{ called: true }])

      subject.subscribe(tester)
      subject.broadcast({ called: "again" })

      expect(tester.recorded).to eq([{ called: "again" }])
    end
  end
end
