module Wikicr::Helpers::History
  class HistoryStorage < Array(String)
    SEPARATOR    = "|"
    KEEP_ENTRIES = 6

    @app : ApplicationController

    def initialize(@app)
      super(1)
    end

    def parse(history_string : String) : self
      history_string.split(SEPARATOR).each do |page|
        push(URI.decode(page))
      end

      self
    end

    def <<(page : Wikicr::Page) : self
      push(page.real_url)
      uniq!
      shift_amount = size - KEEP_ENTRIES
      shift(shift_amount) if shift_amount > 0

      @app.set_cookie name: "user.history", value: URI.encode(to_s), expires: 14.days.from_now, path: "/pages"

      self
    end

    def to_s
      join(SEPARATOR)
    end
  end

  def history : HistoryStorage
    current_history = cookies["user.history"]?
    if current_history
      HistoryStorage.new(self).parse(current_history.value)
    else
      HistoryStorage.new(self)
    end
  end
end
