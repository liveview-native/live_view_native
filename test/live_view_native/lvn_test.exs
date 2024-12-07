defmodule LiveViewNative.LVNTest do
  use ExUnit.Case, async: true

  alias LiveViewNative.LVN

  describe "exec" do
    test "with defaults" do
      assert LVN.exec("phx-remove") == %LVN{ops: [["exec", %{attr: "phx-remove"}]]}

      assert LVN.exec("phx-remove", to: "#modal") == %LVN{
               ops: [["exec", %{attr: "phx-remove", to: "#modal"}]]
             }
    end
  end

  describe "push" do
    test "with defaults" do
      assert LVN.push("inc") == %LVN{ops: [["push", %{event: "inc"}]]}
    end

    test "target" do
      assert LVN.push("inc", target: "#modal") == %LVN{
               ops: [["push", %{event: "inc", target: "#modal"}]]
             }

      assert LVN.push("inc", target: 1) == %LVN{
               ops: [["push", %{event: "inc", target: 1}]]
             }
    end

    test "loading" do
      assert LVN.push("inc", loading: "#modal") == %LVN{
               ops: [["push", %{event: "inc", loading: "#modal"}]]
             }
    end

    test "page_loading" do
      assert LVN.push("inc", page_loading: true) == %LVN{
               ops: [["push", %{event: "inc", page_loading: true}]]
             }
    end

    test "value" do
      assert LVN.push("inc", value: %{one: 1, two: 2}) == %LVN{
               ops: [["push", %{event: "inc", value: %{one: 1, two: 2}}]]
             }

      assert_raise ArgumentError, ~r/push :value expected to be a map/, fn ->
        LVN.push("inc", value: "not-a-map")
      end
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for push/, fn ->
        LVN.push("inc", to: "#modal", bad: :opt)
      end
    end

    test "composability" do
      lvn = LVN.push("inc") |> LVN.push("dec", loading: ".foo")

      assert lvn == %LVN{
               ops: [["push", %{event: "inc"}], ["push", %{event: "dec", loading: ".foo"}]]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.push("inc", value: %{one: 1, two: 2})) ==
               "[[&quot;push&quot;,{&quot;event&quot;:&quot;inc&quot;,&quot;value&quot;:{&quot;one&quot;:1,&quot;two&quot;:2}}]]"
    end
  end

  describe "add_class" do
    test "with defaults" do
      assert LVN.add_class("show") == %LVN{
               ops: [
                 ["add_class", %{names: ["show"]}]
               ]
             }

      assert LVN.add_class("show", to: {:closest, "a"}) == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show"], to: %{closest: "a"}}
                 ]
               ]
             }

      assert LVN.add_class("show", to: "#modal") == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show"], to: "#modal"}
                 ]
               ]
             }
    end

    test "multiple classes" do
      assert LVN.add_class("show hl") == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show", "hl"]}
                 ]
               ]
             }
    end

    test "custom time" do
      assert LVN.add_class("show", time: 543) == %LVN{
               ops: [
                 ["add_class", %{names: ["show"], time: 543}]
               ]
             }
    end

    test "transition" do
      assert LVN.add_class("show", transition: "fade") == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show"], transition: [["fade"], [], []]}
                 ]
               ]
             }

      assert LVN.add_class("show", transition: "fade", blocking: false) == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show"], transition: [["fade"], [], []], blocking: false}
                 ]
               ]
             }

      assert LVN.add_class("c", transition: "a b") == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["c"], transition: [["a", "b"], [], []]}
                 ]
               ]
             }

      assert LVN.add_class("show", transition: {"fade", "opacity-0", "opacity-100"}) == %LVN{
               ops: [
                 [
                   "add_class",
                   %{
                     names: ["show"],
                     transition: [["fade"], ["opacity-0"], ["opacity-100"]]
                   }
                 ]
               ]
             }
    end

    test "composability" do
      lvn = LVN.add_class("show", to: "#modal", time: 100) |> LVN.add_class("hl")

      assert lvn == %LVN{
               ops: [
                 [
                   "add_class",
                   %{names: ["show"], time: 100, to: "#modal"}
                 ],
                 ["add_class", %{names: ["hl"]}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for add_class/, fn ->
        LVN.add_class("show", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in add_class/, fn ->
        LVN.add_class("show", to: {:sibling, "foo"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.add_class("show")) ==
               "[[&quot;add_class&quot;,{&quot;names&quot;:[&quot;show&quot;]}]]"
    end
  end

  describe "remove_class" do
    test "with defaults" do
      assert LVN.remove_class("show") == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"]}
                 ]
               ]
             }

      assert LVN.remove_class("show", to: "#modal") == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], to: "#modal"}
                 ]
               ]
             }

      assert LVN.remove_class("show", to: {:inner, "a"}) == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], to: %{inner: "a"}}
                 ]
               ]
             }
    end

    test "multiple classes" do
      assert LVN.remove_class("show hl") == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show", "hl"]}
                 ]
               ]
             }
    end

    test "custom time" do
      assert LVN.remove_class("show", time: 543) == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], time: 543}
                 ]
               ]
             }
    end

    test "transition" do
      assert LVN.remove_class("show", transition: "fade") == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], transition: [["fade"], [], []]}
                 ]
               ]
             }

      assert LVN.remove_class("show", transition: "fade", blocking: false) == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], transition: [["fade"], [], []], blocking: false}
                 ]
               ]
             }

      assert LVN.remove_class("c", transition: "a b") == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["c"], transition: [["a", "b"], [], []]}
                 ]
               ]
             }

      assert LVN.remove_class("show", transition: {"fade", "opacity-0", "opacity-100"}) == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{
                     names: ["show"],
                     transition: [["fade"], ["opacity-0"], ["opacity-100"]]
                   }
                 ]
               ]
             }
    end

    test "composability" do
      lvn = LVN.remove_class("show", to: "#modal", time: 100) |> LVN.remove_class("hl")

      assert lvn == %LVN{
               ops: [
                 [
                   "remove_class",
                   %{names: ["show"], time: 100, to: "#modal"}
                 ],
                 ["remove_class", %{names: ["hl"]}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for remove_class/, fn ->
        LVN.remove_class("show", bad: :opt)
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.remove_class("show")) ==
               "[[&quot;remove_class&quot;,{&quot;names&quot;:[&quot;show&quot;]}]]"
    end
  end

  describe "toggle_class" do
    test "with defaults" do
      assert LVN.toggle_class("show") == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"]}
                 ]
               ]
             }

      assert LVN.toggle_class("show", to: "#modal") == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], to: "#modal"}
                 ]
               ]
             }

      assert LVN.toggle_class("show", to: {:document, "#modal"}) == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], to: "#modal"}
                 ]
               ]
             }
    end

    test "multiple classes" do
      assert LVN.toggle_class("show hl") == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show", "hl"]}
                 ]
               ]
             }
    end

    test "custom time" do
      assert LVN.toggle_class("show", time: 543) == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], time: 543}
                 ]
               ]
             }
    end

    test "transition" do
      assert LVN.toggle_class("show", transition: "fade") == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], transition: [["fade"], [], []]}
                 ]
               ]
             }

      assert LVN.toggle_class("show", transition: "fade", blocking: false) == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], transition: [["fade"], [], []], blocking: false}
                 ]
               ]
             }

      assert LVN.toggle_class("c", transition: "a b") == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["c"], transition: [["a", "b"], [], []]}
                 ]
               ]
             }

      assert LVN.toggle_class("show", transition: {"fade", "opacity-0", "opacity-100"}) == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{
                     names: ["show"],
                     transition: [["fade"], ["opacity-0"], ["opacity-100"]]
                   }
                 ]
               ]
             }
    end

    test "composability" do
      lvn = LVN.toggle_class("show", to: "#modal", time: 100) |> LVN.toggle_class("hl")

      assert lvn == %LVN{
               ops: [
                 [
                   "toggle_class",
                   %{names: ["show"], time: 100, to: "#modal"}
                 ],
                 ["toggle_class", %{names: ["hl"]}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for toggle_class/, fn ->
        LVN.toggle_class("show", bad: :opt)
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.toggle_class("show")) ==
               "[[&quot;toggle_class&quot;,{&quot;names&quot;:[&quot;show&quot;]}]]"
    end
  end

  describe "dispatch" do
    test "with defaults" do
      assert LVN.dispatch("click", to: "#modal") == %LVN{
               ops: [["dispatch", %{to: "#modal", event: "click"}]]
             }

      assert LVN.dispatch("click") == %LVN{
               ops: [["dispatch", %{event: "click"}]]
             }
    end

    test "with optional flags" do
      assert LVN.dispatch("click", bubbles: false) == %LVN{
               ops: [["dispatch", %{event: "click", bubbles: false}]]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for dispatch/, fn ->
        LVN.dispatch("click", to: ".foo", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in dispatch/, fn ->
        LVN.dispatch("click", to: {:winner, ".foo"})
      end
    end

    test "raises with click details" do
      assert_raise ArgumentError, ~r/click events cannot be dispatched with details/, fn ->
        LVN.dispatch("click", to: ".foo", detail: %{id: 123})
      end
    end

    test "composability" do
      lvn =
        LVN.dispatch("click", to: "#modal")
        |> LVN.dispatch("keydown", to: "#keyboard")
        |> LVN.dispatch("keyup")

      assert lvn == %LVN{
               ops: [
                 ["dispatch", %{to: "#modal", event: "click"}],
                 ["dispatch", %{to: "#keyboard", event: "keydown"}],
                 ["dispatch", %{event: "keyup"}]
               ]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.dispatch("click", to: ".foo")) ==
               "[[&quot;dispatch&quot;,{&quot;event&quot;:&quot;click&quot;,&quot;to&quot;:&quot;.foo&quot;}]]"
    end
  end

  describe "toggle" do
    test "with defaults" do
      assert LVN.toggle(to: "#modal") == %LVN{
               ops: [
                 [
                   "toggle",
                   %{to: "#modal"}
                 ]
               ]
             }

      assert LVN.toggle(to: {:closest, ".modal"}) == %LVN{
               ops: [
                 [
                   "toggle",
                   %{to: %{closest: ".modal"}}
                 ]
               ]
             }
    end

    test "in and out classes" do
      assert LVN.toggle(to: "#modal", in: "fade-in d-block", out: "fade-out d-block") ==
               %LVN{
                 ops: [
                   [
                     "toggle",
                     %{
                       ins: [["fade-in", "d-block"], [], []],
                       outs: [["fade-out", "d-block"], [], []],
                       to: "#modal"
                     }
                   ]
                 ]
               }

      assert LVN.toggle(
               to: "#modal",
               in: {"fade-in", "opacity-0", "opacity-100"},
               out: {"fade-out", "opacity-100", "opacity-0"}
             ) ==
               %LVN{
                 ops: [
                   [
                     "toggle",
                     %{
                       ins: [["fade-in"], ["opacity-0"], ["opacity-100"]],
                       outs: [["fade-out"], ["opacity-100"], ["opacity-0"]],
                       to: "#modal"
                     }
                   ]
                 ]
               }
    end

    test "custom time" do
      assert LVN.toggle(to: "#modal", time: 123) == %LVN{
               ops: [
                 [
                   "toggle",
                   %{time: 123, to: "#modal"}
                 ]
               ]
             }
    end

    test "custom display" do
      assert LVN.toggle(to: "#modal", display: "block") == %LVN{
               ops: [
                 [
                   "toggle",
                   %{
                     display: "block",
                     to: "#modal"
                   }
                 ]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for toggle/, fn ->
        LVN.toggle(to: "#modal", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in toggle/, fn ->
        LVN.toggle(to: "#modal", to: {:bad, "123"})
      end
    end

    test "composability" do
      lvn = LVN.toggle(to: "#modal") |> LVN.toggle(to: "#keyboard", time: 123)

      assert lvn == %LVN{
               ops: [
                 ["toggle", %{to: "#modal"}],
                 ["toggle", %{to: "#keyboard", time: 123}]
               ]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.toggle(to: "#modal")) ==
               "[[&quot;toggle&quot;,{&quot;to&quot;:&quot;#modal&quot;}]]"
    end
  end

  describe "show" do
    test "with defaults" do
      assert LVN.show(to: "#modal") == %LVN{
               ops: [["show", %{to: "#modal"}]]
             }

      assert LVN.show(to: {:inner, ".modal"}) == %LVN{
               ops: [["show", %{to: %{inner: ".modal"}}]]
             }
    end

    test "transition classes" do
      assert LVN.show(to: "#modal", transition: "fade-in d-block") ==
               %LVN{
                 ops: [
                   [
                     "show",
                     %{
                       transition: [["fade-in", "d-block"], [], []],
                       to: "#modal"
                     }
                   ]
                 ]
               }

      assert LVN.show(
               to: "#modal",
               transition:
                 {"fade-in d-block", "opacity-0 -translate-x-full", "opacity-100 translate-x-0"}
             ) ==
               %LVN{
                 ops: [
                   [
                     "show",
                     %{
                       transition: [
                         ["fade-in", "d-block"],
                         ["opacity-0", "-translate-x-full"],
                         ["opacity-100", "translate-x-0"]
                       ],
                       to: "#modal"
                     }
                   ]
                 ]
               }
    end

    test "custom time" do
      assert LVN.show(to: "#modal", time: 123) == %LVN{
               ops: [["show", %{time: 123, to: "#modal"}]]
             }
    end

    test "custom display" do
      assert LVN.show(to: "#modal", display: "block") == %LVN{
               ops: [
                 ["show", %{display: "block", to: "#modal"}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for show/, fn ->
        LVN.show(to: "#modal", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in show/, fn ->
        LVN.show(to: {:bad, "#modal"})
      end
    end

    test "composability" do
      lvn = LVN.show(to: "#modal") |> LVN.show(to: "#keyboard", time: 123)

      assert lvn == %LVN{
               ops: [
                 ["show", %{to: "#modal"}],
                 ["show", %{to: "#keyboard", time: 123}]
               ]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.show(to: "#modal")) ==
               "[[&quot;show&quot;,{&quot;to&quot;:&quot;#modal&quot;}]]"
    end
  end

  describe "hide" do
    test "with defaults" do
      assert LVN.hide(to: "#modal") == %LVN{
               ops: [["hide", %{to: "#modal"}]]
             }

      assert LVN.hide(to: {:closest, "a"}) == %LVN{
               ops: [["hide", %{to: %{closest: "a"}}]]
             }
    end

    test "transition classes" do
      assert LVN.hide(to: "#modal", transition: "fade-out d-block") ==
               %LVN{
                 ops: [
                   [
                     "hide",
                     %{
                       transition: [["fade-out", "d-block"], [], []],
                       to: "#modal"
                     }
                   ]
                 ]
               }

      assert LVN.hide(
               to: "#modal",
               transition:
                 {"fade-in d-block", "opacity-0 -translate-x-full", "opacity-100 translate-x-0"}
             ) ==
               %LVN{
                 ops: [
                   [
                     "hide",
                     %{
                       transition: [
                         ["fade-in", "d-block"],
                         ["opacity-0", "-translate-x-full"],
                         ["opacity-100", "translate-x-0"]
                       ],
                       to: "#modal"
                     }
                   ]
                 ]
               }
    end

    test "custom time" do
      assert LVN.hide(to: "#modal", time: 123) == %LVN{
               ops: [["hide", %{time: 123, to: "#modal"}]]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for hide/, fn ->
        LVN.hide(to: "#modal", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in hide/, fn ->
        LVN.hide(to: {:bad, "#modal"})
      end
    end

    test "composability" do
      lvn = LVN.hide(to: "#modal") |> LVN.hide(to: "#keyboard", time: 123)

      assert lvn == %LVN{
               ops: [
                 ["hide", %{to: "#modal"}],
                 ["hide", %{to: "#keyboard", time: 123}]
               ]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.hide(to: "#modal")) ==
               "[[&quot;hide&quot;,{&quot;to&quot;:&quot;#modal&quot;}]]"
    end
  end

  describe "transition" do
    test "with defaults" do
      assert LVN.transition("shake") == %LVN{
               ops: [["transition", %{transition: [["shake"], [], []]}]]
             }

      assert LVN.transition("shake", to: "#modal") == %LVN{
               ops: [["transition", %{transition: [["shake"], [], []], to: "#modal"}]]
             }

      assert LVN.transition("shake", to: {:inner, "a"}) == %LVN{
               ops: [["transition", %{transition: [["shake"], [], []], to: %{inner: "a"}}]]
             }

      assert LVN.transition("shake swirl", to: "#modal") == %LVN{
               ops: [
                 [
                   "transition",
                   %{transition: [["shake", "swirl"], [], []], to: "#modal"}
                 ]
               ]
             }

      assert LVN.transition({"shake swirl", "opacity-0 a", "opacity-100 b"}, to: "#modal") == %LVN{
               ops: [
                 [
                   "transition",
                   %{
                     transition: [["shake", "swirl"], ["opacity-0", "a"], ["opacity-100", "b"]],
                     to: "#modal"
                   }
                 ]
               ]
             }
    end

    test "custom time" do
      assert LVN.transition("shake", to: "#modal", time: 123) == %LVN{
               ops: [["transition", %{transition: [["shake"], [], []], time: 123, to: "#modal"}]]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for transition/, fn ->
        LVN.transition("shake", to: "#modal", bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in transition/, fn ->
        LVN.transition("shake", to: {:bad, "#modal"})
      end
    end

    test "composability" do
      lvn = LVN.transition("shake", to: "#modal") |> LVN.transition("hl", to: "#keyboard", time: 123)

      assert lvn == %LVN{
               ops: [
                 ["transition", %{to: "#modal", transition: [["shake"], [], []]}],
                 ["transition", %{to: "#keyboard", transition: [["hl"], [], []], time: 123}]
               ]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.transition("shake", to: "#modal")) ==
               "[[&quot;transition&quot;,{&quot;to&quot;:&quot;#modal&quot;,&quot;transition&quot;:[[&quot;shake&quot;],[],[]]}]]"
    end
  end

  describe "set_attribute" do
    test "with defaults" do
      assert LVN.set_attribute({"aria-expanded", "true"}) == %LVN{
               ops: [
                 ["set_attr", %{attr: ["aria-expanded", "true"]}]
               ]
             }

      assert LVN.set_attribute({"aria-expanded", "true"}, to: "#dropdown") == %LVN{
               ops: [
                 ["set_attr", %{attr: ["aria-expanded", "true"], to: "#dropdown"}]
               ]
             }

      assert LVN.set_attribute({"aria-expanded", "true"}, to: {:inner, ".dropdown"}) == %LVN{
               ops: [
                 ["set_attr", %{attr: ["aria-expanded", "true"], to: %{inner: ".dropdown"}}]
               ]
             }
    end

    test "composability" do
      lvn =
        LVN.set_attribute({"expanded", "true"})
        |> LVN.set_attribute({"has-popup", "true"})
        |> LVN.set_attribute({"has-popup", "true"}, to: "#dropdown")

      assert lvn == %LVN{
               ops: [
                 ["set_attr", %{attr: ["expanded", "true"]}],
                 ["set_attr", %{attr: ["has-popup", "true"]}],
                 ["set_attr", %{to: "#dropdown", attr: ["has-popup", "true"]}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for set_attribute/, fn ->
        LVN.set_attribute({"disabled", ""}, bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in set_attribute/, fn ->
        LVN.set_attribute({"disabled", ""}, to: {:bad, "#modal"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.set_attribute({"disabled", "true"})) ==
               "[[&quot;set_attr&quot;,{&quot;attr&quot;:[&quot;disabled&quot;,&quot;true&quot;]}]]"
    end
  end

  describe "remove_attribute" do
    test "with defaults" do
      assert LVN.remove_attribute("aria-expanded") == %LVN{
               ops: [
                 ["remove_attr", %{attr: "aria-expanded"}]
               ]
             }

      assert LVN.remove_attribute("aria-expanded", to: "#dropdown") == %LVN{
               ops: [
                 ["remove_attr", %{attr: "aria-expanded", to: "#dropdown"}]
               ]
             }
    end

    test "composability" do
      lvn =
        LVN.remove_attribute("expanded")
        |> LVN.remove_attribute("has-popup")
        |> LVN.remove_attribute("has-popup", to: "#dropdown")

      assert lvn == %LVN{
               ops: [
                 ["remove_attr", %{attr: "expanded"}],
                 ["remove_attr", %{attr: "has-popup"}],
                 ["remove_attr", %{to: "#dropdown", attr: "has-popup"}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for remove_attribute/, fn ->
        LVN.remove_attribute("disabled", bad: :opt)
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.remove_attribute("disabled")) ==
               "[[&quot;remove_attr&quot;,{&quot;attr&quot;:&quot;disabled&quot;}]]"
    end
  end

  describe "toggle_attribute" do
    test "with defaults" do
      assert LVN.toggle_attribute({"open", "true"}) == %LVN{
               ops: [
                 ["toggle_attr", %{attr: ["open", "true"]}]
               ]
             }

      assert LVN.toggle_attribute({"open", "true"}, to: "#dropdown") == %LVN{
               ops: [
                 ["toggle_attr", %{attr: ["open", "true"], to: "#dropdown"}]
               ]
             }

      assert LVN.toggle_attribute({"aria-expanded", "true", "false"}, to: "#dropdown") == %LVN{
               ops: [
                 ["toggle_attr", %{attr: ["aria-expanded", "true", "false"], to: "#dropdown"}]
               ]
             }

      assert LVN.toggle_attribute({"aria-expanded", "true", "false"}, to: {:inner, ".dropdown"}) ==
               %LVN{
                 ops: [
                   [
                     "toggle_attr",
                     %{attr: ["aria-expanded", "true", "false"], to: %{inner: ".dropdown"}}
                   ]
                 ]
               }
    end

    test "composability" do
      lvn =
        {"aria-expanded", "true", "false"}
        |> LVN.toggle_attribute()
        |> LVN.toggle_attribute({"open", "true"})
        |> LVN.toggle_attribute({"disabled", "true"}, to: "#dropdown")

      assert lvn == %LVN{
               ops: [
                 ["toggle_attr", %{attr: ["aria-expanded", "true", "false"]}],
                 ["toggle_attr", %{attr: ["open", "true"]}],
                 ["toggle_attr", %{to: "#dropdown", attr: ["disabled", "true"]}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for toggle_attribute/, fn ->
        LVN.toggle_attribute({"disabled", "true"}, bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in toggle_attribute/, fn ->
        LVN.toggle_attribute({"disabled", "true"}, to: {:bad, "123"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.toggle_attribute({"disabled", "true"})) ==
               "[[&quot;toggle_attr&quot;,{&quot;attr&quot;:[&quot;disabled&quot;,&quot;true&quot;]}]]"

      assert lvn_to_string(LVN.toggle_attribute({"aria-expanded", "true", "false"})) ==
               "[[&quot;toggle_attr&quot;,{&quot;attr&quot;:[&quot;aria-expanded&quot;,&quot;true&quot;,&quot;false&quot;]}]]"
    end
  end

  describe "focus" do
    test "with defaults" do
      assert LVN.focus() == %LVN{ops: [["focus", %{}]]}
      assert LVN.focus(to: "input") == %LVN{ops: [["focus", %{to: "input"}]]}
      assert LVN.focus(to: {:inner, "input"}) == %LVN{ops: [["focus", %{to: %{inner: "input"}}]]}
    end

    test "composability" do
      lvn =
        LVN.set_attribute({"expanded", "true"})
        |> LVN.focus()

      assert lvn == %LVN{
               ops: [["set_attr", %{attr: ["expanded", "true"]}], ["focus", %{}]]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for focus/, fn ->
        LVN.focus(bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in focus/, fn ->
        LVN.focus(to: {:bad, "a"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.focus()) == "[[&quot;focus&quot;,{}]]"
    end
  end

  describe "focus_first" do
    test "with defaults" do
      assert LVN.focus_first() == %LVN{ops: [["focus_first", %{}]]}
      assert LVN.focus_first(to: "input") == %LVN{ops: [["focus_first", %{to: "input"}]]}

      assert LVN.focus_first(to: {:inner, "input"}) == %LVN{
               ops: [["focus_first", %{to: %{inner: "input"}}]]
             }
    end

    test "composability" do
      lvn =
        LVN.set_attribute({"expanded", "true"})
        |> LVN.focus_first()

      assert lvn == %LVN{
               ops: [
                 ["set_attr", %{attr: ["expanded", "true"]}],
                 ["focus_first", %{}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for focus_first/, fn ->
        LVN.focus_first(bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in focus_first/, fn ->
        LVN.focus_first(to: {:bad, "a"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.focus_first()) == "[[&quot;focus_first&quot;,{}]]"
    end
  end

  describe "push_focus" do
    test "with defaults" do
      assert LVN.push_focus() == %LVN{ops: [["push_focus", %{}]]}
      assert LVN.push_focus(to: "input") == %LVN{ops: [["push_focus", %{to: "input"}]]}

      assert LVN.push_focus(to: {:inner, "input"}) == %LVN{
               ops: [["push_focus", %{to: %{inner: "input"}}]]
             }
    end

    test "composability" do
      lvn =
        LVN.set_attribute({"expanded", "true"})
        |> LVN.push_focus()

      assert lvn == %LVN{
               ops: [
                 ["set_attr", %{attr: ["expanded", "true"]}],
                 ["push_focus", %{}]
               ]
             }
    end

    test "raises with unknown options" do
      assert_raise ArgumentError, ~r/invalid option for push_focus/, fn ->
        LVN.push_focus(bad: :opt)
      end

      assert_raise ArgumentError, ~r/invalid scope for :to option in push_focus/, fn ->
        LVN.push_focus(to: {:bad, "a"})
      end
    end

    test "encoding" do
      assert lvn_to_string(LVN.push_focus()) == "[[&quot;push_focus&quot;,{}]]"
    end
  end

  describe "pop_focus" do
    test "with defaults" do
      assert LVN.pop_focus() == %LVN{ops: [["pop_focus", %{}]]}
    end

    test "composability" do
      lvn =
        LVN.set_attribute({"expanded", "true"})
        |> LVN.pop_focus()

      assert lvn == %LVN{
               ops: [["set_attr", %{attr: ["expanded", "true"]}], ["pop_focus", %{}]]
             }
    end

    test "encoding" do
      assert lvn_to_string(LVN.pop_focus()) == "[[&quot;pop_focus&quot;,{}]]"
    end
  end

  describe "concat" do
    test "combines multiple LVN structs" do
      lvn1 = LVN.push("inc", value: %{one: 1, two: 2})
      lvn2 = LVN.add_class("show", to: "#modal", time: 100)
      lvn3 = LVN.remove_class("show")

      assert LVN.concat(lvn1, lvn2) |> LVN.concat(lvn3) == %LVN{
               ops: [
                 ["push", %{event: "inc", value: %{one: 1, two: 2}}],
                 ["add_class", %{names: ["show"], time: 100, to: "#modal"}],
                 ["remove_class", %{names: ["show"]}]
               ]
             }
    end
  end

  defp lvn_to_string(%LVN{} = lvn) do
    lvn
    |> Map.update!(:ops, &order_ops_map_keys/1)
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp order_ops_map_keys(ops) when is_list(ops) do
    Enum.map(ops, &order_ops_map_keys/1)
  end

  defp order_ops_map_keys(ops) when is_map(ops) do
    ops
    |> Enum.map(&order_ops_map_keys/1)
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Jason.OrderedObject.new()
  end

  defp order_ops_map_keys(ops) do
    ops
  end
end
