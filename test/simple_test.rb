require "jekyll_sqlite"

class SimpleTest < Minitest::Test
  def g
    JekyllSQlite::Generator.new
  end

  def test_init
    JekyllSQlite::Generator.new
  end

  def test_db_setup
    db = SQLite3::Database.new(":memory:")
    g.fast_setup db

    assert_equal(0, db.execute("PRAGMA synchronous")[0][0])
    assert_equal("off", db.execute("PRAGMA journal_mode")[0][0])
    assert_equal(1, db.execute("PRAGMA query_only")[0][0])
  end

  def test_get_root
    t = { "a" => { "b" => { "c" => false } } }

    assert_equal g.get_root(t, ""), t
    assert_equal g.get_root(t, "a"), t
    assert_equal g.get_root(t, "a.b"), t["a"]
    assert_equal g.get_root(t, "a.b.c"), t["a"]["b"]
  end

  def test_get_tip
    assert_equal("b", g.get_tip("a.b"))
    assert_equal("c", g.get_tip("a.b.c"))
    assert_equal("members", g.get_tip("members"))
  end
end
