describe('xi.moment.datetime', function()
  local moment = require 'xi.moment'
  require 'xi.moment.datetime'
  local TZ = ''
  if moment.system_tz ~= 3600 then
    TZ = '+0100'
  end

  describe('start_of_year', function()
    it('works on local time', function()
      local m = moment.parse("2016-12-12T19:39:25"):start_of_year()
      assert.equal(2016, m.year)
      assert.equal(1, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(6, m.wday)
      assert.equal(1, m.yday)
      assert.equal(moment.system_tz, m.tz)
      if moment.system_tz == 0 then
        assert.equal("2016-01-01T00:00:00Z", tostring(m))
      else
        assert.equal("2016-01-01T00:00:00", tostring(m))
      end
    end)

    it('works on UTC', function()
      local m = moment.parse("2016-12-12T19:39:25Z"):start_of_year()
      assert.equal(2016, m.year)
      assert.equal(1, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(6, m.wday)
      assert.equal(1, m.yday)
      assert.equal(0, m.tz)
      assert.equal("2016-01-01T00:00:00Z", tostring(m))
    end)

    it('works on arbitrary timezone', function()
      local m = moment.parse("2016-12-12T19:39:25+0100"):start_of_year()
      assert.equal(2016, m.year)
      assert.equal(1, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(6, m.wday)
      assert.equal(1, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-01-01T00:00:00", tostring(m))
      else
        assert.equal("2016-01-01T00:00:00+0100", tostring(m))
      end
    end)
  end)

  describe('start_of_month', function()
    it('works on local time', function()
      local m = moment.parse("2016-12-12T19:39:25"):start_of_month()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(5, m.wday)
      assert.equal(336, m.yday)
      assert.equal(moment.system_tz, m.tz)
      if moment.system_tz == 0 then
        assert.equal("2016-12-01T00:00:00Z", tostring(m))
      else
        assert.equal("2016-12-01T00:00:00", tostring(m))
      end
    end)

    it('works on UTC', function()
      local m = moment.parse("2016-12-12T19:39:25Z"):start_of_month()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(5, m.wday)
      assert.equal(336, m.yday)
      assert.equal(0, m.tz)
      assert.equal("2016-12-01T00:00:00Z", tostring(m))
    end)

    it('works on arbitrary timezone', function()
      local m = moment.parse("2016-12-12T19:39:25+0100"):start_of_year()
      assert.equal(2016, m.year)
      assert.equal(1, m.month)
      assert.equal(1, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(6, m.wday)
      assert.equal(1, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-01-01T00:00:00", tostring(m))
      else
        assert.equal("2016-01-01T00:00:00+0100", tostring(m))
      end
    end)
  end)

  describe('start_of_day', function()
    it('works on local time', function()
      local m = moment.parse("2016-12-12T19:39:25"):start_of_day()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(moment.system_tz, m.tz)
      if moment.system_tz == 0 then
        assert.equal("2016-12-12T00:00:00Z", tostring(m))
      else
        assert.equal("2016-12-12T00:00:00", tostring(m))
      end
    end)

    it('works on UTC', function()
      local m = moment.parse("2016-12-12T19:39:25Z"):start_of_day()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(0, m.tz)
      assert.equal("2016-12-12T00:00:00Z", tostring(m))
    end)

    it('works on arbitrary timezone', function()
      local m = moment.parse("2016-12-12T19:39:25+0100"):start_of_day()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-12T00:00:00", tostring(m))
      else
        assert.equal("2016-12-12T00:00:00+0100", tostring(m))
      end
    end)
  end)

  describe('end_of_year', function()
    it('works on local time', function()
      local m = moment.parse("2016-12-12T19:39:25"):end_of_year()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(31, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(7, m.wday)
      assert.equal(366, m.yday)
      assert.equal(moment.system_tz, m.tz)
      if moment.system_tz == 0 then
        assert.equal("2016-12-31T23:59:59Z", tostring(m))
      else
        assert.equal("2016-12-31T23:59:59", tostring(m))
      end
    end)

    it('works on UTC', function()
      local m = moment.parse("2016-12-12T19:39:25Z"):end_of_year()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(31, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(7, m.wday)
      assert.equal(366, m.yday)
      assert.equal(0, m.tz)
      assert.equal("2016-12-31T23:59:59Z", tostring(m))
    end)

    it('works on arbitrary timezone', function()
      local m = moment.parse("2016-12-12T19:39:25+0100"):end_of_year()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(31, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(7, m.wday)
      assert.equal(366, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-31T23:59:59", tostring(m))
      else
        assert.equal("2016-12-31T23:59:59+0100", tostring(m))
      end
    end)
  end)

  describe('end_of_month', function()
    it('works on leap month', function()
      local m = moment.parse("2016-02-12T19:39:25+0100"):end_of_month()
      assert.equal(2016, m.year)
      assert.equal(2, m.month)
      assert.equal(29, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(2, m.wday)
      assert.equal(60, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-02-29T23:59:59", tostring(m))
      else
        assert.equal("2016-02-29T23:59:59+0100", tostring(m))
      end
    end)
  end)

  describe('end_of_day', function()
    it('works on arbitrary timezone', function()
      local m = moment.parse("2016-12-12T00:00:25+0100"):end_of_day()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-12T23:59:59", tostring(m))
      else
        assert.equal("2016-12-12T23:59:59+0100", tostring(m))
      end
    end)
  end)

  describe('start_of_week_starting_with_sunday', function()
    it('returns the same day on Sun', function()
      local m = moment.parse("2016-12-11T01:02:25+0100"):start_of_week_starting_with_sunday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(11, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(1, m.wday)
      assert.equal(346, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-11T00:00:00", tostring(m))
      else
        assert.equal("2016-12-11T00:00:00+0100", tostring(m))
      end
    end)

    it('returns the 6 days ago on Sat', function()
      local m = moment.parse("2016-12-17T01:02:25+0100"):start_of_week_starting_with_sunday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(11, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(1, m.wday)
      assert.equal(346, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-11T00:00:00", tostring(m))
      else
        assert.equal("2016-12-11T00:00:00+0100", tostring(m))
      end
    end)
  end)

  describe('end_of_week_starting_with_sunday', function()
    it('returns the 6 days in future on Sun', function()
      local m = moment.parse("2016-12-11T01:02:25+0100"):end_of_week_starting_with_sunday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(17, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(7, m.wday)
      assert.equal(352, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-17T23:59:59", tostring(m))
      else
        assert.equal("2016-12-17T23:59:59+0100", tostring(m))
      end
    end)

    it('returns the same day on Sat', function()
      local m = moment.parse("2016-12-17T01:02:25+0100"):end_of_week_starting_with_sunday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(17, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(7, m.wday)
      assert.equal(352, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-17T23:59:59", tostring(m))
      else
        assert.equal("2016-12-17T23:59:59+0100", tostring(m))
      end
    end)
  end)

  describe('start_of_week_starting_with_monday', function()
    it('returns the same day on Mon', function()
      local m = moment.parse("2016-12-12T01:02:25+0100"):start_of_week_starting_with_monday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-12T00:00:00", tostring(m))
      else
        assert.equal("2016-12-12T00:00:00+0100", tostring(m))
      end
    end)

    it('returns the 6 days ago on Sun', function()
      local m = moment.parse("2016-12-18T01:02:25+0100"):start_of_week_starting_with_monday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(12, m.day)
      assert.equal(0, m.hour)
      assert.equal(0, m.min)
      assert.equal(0, m.sec)
      assert.equal(2, m.wday)
      assert.equal(347, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-12T00:00:00", tostring(m))
      else
        assert.equal("2016-12-12T00:00:00+0100", tostring(m))
      end
    end)
  end)

  describe('end_of_week_starting_with_monday', function()
    it('returns the 6 days in future on Mon', function()
      local m = moment.parse("2016-12-12T01:02:25+0100"):end_of_week_starting_with_monday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(18, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(1, m.wday)
      assert.equal(353, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-18T23:59:59", tostring(m))
      else
        assert.equal("2016-12-18T23:59:59+0100", tostring(m))
      end
    end)

    it('returns the same day on Sun', function()
      local m = moment.parse("2016-12-18T01:02:25+0100"):end_of_week_starting_with_monday()
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(18, m.day)
      assert.equal(23, m.hour)
      assert.equal(59, m.min)
      assert.equal(59, m.sec)
      assert.equal(1, m.wday)
      assert.equal(353, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-18T23:59:59", tostring(m))
      else
        assert.equal("2016-12-18T23:59:59+0100", tostring(m))
      end
    end)
  end)

  describe('next_wday', function()
    it('returns day in wday - current wday if wday > current wday', function()
      local m = moment.parse("2016-12-13T01:02:25+0100"):next_wday(4, 18, 1, 2)
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(14, m.day)
      assert.equal(18, m.hour)
      assert.equal(1, m.min)
      assert.equal(2, m.sec)
      assert.equal(4, m.wday)
      assert.equal(349, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-14T18:01:02", tostring(m))
      else
        assert.equal("2016-12-14T18:01:02+0100", tostring(m))
      end
    end)

    it('returns day in wday + 7 - current wday if wday < current wday', function()
      local m = moment.parse("2016-12-13T01:02:25+0100"):next_wday(2, 18, 1, 2)
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(19, m.day)
      assert.equal(18, m.hour)
      assert.equal(1, m.min)
      assert.equal(2, m.sec)
      assert.equal(2, m.wday)
      assert.equal(354, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-19T18:01:02", tostring(m))
      else
        assert.equal("2016-12-19T18:01:02+0100", tostring(m))
      end
    end)

    it('returns current day if wday == current wday and time is in future', function()
      local m = moment.parse("2016-12-13T01:02:25+0100"):next_wday(3, 1, 2, 25)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-13T01:02:25", tostring(m))
      else
        assert.equal("2016-12-13T01:02:25+0100", tostring(m))
      end
    end)
    it('returns current day if wday == current wday and time is in future', function()
      local m = moment.parse("2016-12-13T01:02:25+0100"):next_wday(3, 18, 1, 2)
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(13, m.day)
      assert.equal(18, m.hour)
      assert.equal(1, m.min)
      assert.equal(2, m.sec)
      assert.equal(3, m.wday)
      assert.equal(348, m.yday)
      assert.equal(3600, m.tz)
      if moment.system_tz == 3600 then
        assert.equal("2016-12-13T18:01:02", tostring(m))
      else
        assert.equal("2016-12-13T18:01:02+0100", tostring(m))
      end
    end)

    it('returns next week if wday == current wday and time is in the past', function()
      local m = moment.parse("2016-12-13T01:02:25+0100"):next_wday(3, 1, 1, 2)
      assert.equal(2016, m.year)
      assert.equal(12, m.month)
      assert.equal(20, m.day)
      assert.equal(1, m.hour)
      assert.equal(1, m.min)
      assert.equal(2, m.sec)
      assert.equal(3, m.wday)
      assert.equal(355, m.yday)
      assert.equal(3600, m.tz)
      assert.equal("2016-12-20T01:01:02" .. TZ, tostring(m))
    end)
  end)

  describe('change', function()
    it('changes tz without changing time', function()
      assert.equal("2016-12-13T01:02:03" .. TZ, tostring(moment.parse("2016-12-13T01:02:03Z"):change({ tz = 3600 })))
    end)
    it('handles overflow', function()
      local m = moment.parse("2016-12-13T01:02:03+0100"):change({ day = -1 })

      assert.equal("2016-11-29T01:02:03" .. TZ, tostring(m))
    end)
    it('changes multiple fields', function()
      local m = moment.parse("2016-12-13T01:02:03+0100"):change({ day = -1, month = 11 })

      assert.equal("2016-10-30T01:02:03" .. TZ, tostring(m))
    end)
  end)
end)
