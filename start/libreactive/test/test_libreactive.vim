vim9script

import 'libtinytest.vim'           as tt
import '../import/libreactive.vim' as react

react.debug_level = 0
react.queue_size  = 100

class Dummy
  var value: number
endclass

class X
  var result: number

  def new(px: react.Property)
    react.CreateEffect(() => {
      this.result = px.Get()
    })
  enddef
endclass

class ChildProperty extends react.Property
  def new(value: string, args: dict<any> = {})
    this.value = value
    super.Init(args)
  enddef

  def Set(newValue: string, args: dict<any> = {})
    if !args->get('force', false)
      return
    endif

    var concatenatedValue = this.value .. newValue
    super.Set(concatenatedValue)
  enddef
endclass

def GetSet(value: any): list<func>
  var p = react.Property.new(value)
  return [p.Get, p.Set]
enddef

def Test_React_Version()
  assert_true(match(react.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

def Test_React_PropertyAttributes()
  var p0 = react.Property.new('x')

  assert_equal('x',    p0.value)
  assert_equal('x',    p0.Get())
  assert_equal([],     p0.effects)
  assert_match('x', string(p0))
enddef

def Test_React_SimpleProperty()
  var cnt = react.Property.new(2)
  const DoubleCount = () => cnt.Get() * 2

  assert_equal(4, DoubleCount())

  cnt.Set(3)

  assert_equal(6, DoubleCount())

  cnt.Set(cnt.Get() + 2)

  assert_equal(10, DoubleCount())

  # A property's value can be read and written directly
  assert_equal(5, cnt.value)

  cnt.value = 6

  assert_equal(6, cnt.Get())
enddef

def Test_React_SimpleEffect()
  var result = 0
  var p0 = react.Property.new(1)
  var E  = () => {
    result = p0.Get()
  }

  var effect = react.CreateEffect(E)

  assert_equal(E, effect.Fn)
  assert_equal(0, effect.weight)
  assert_equal([p0], effect.dependentProperties)

  assert_equal(1, result)

  p0.Set(2)

  assert_equal(2, result)

  p0.Set(p0.Get() * 3)

  assert_equal(6, result)
enddef

# Setting the same value should not trigger any effect
def Test_React_SetSameValue()
  var p0 = react.Property.new('hello')
  var result = 49

  react.CreateEffect(() => {
    p0.Get()
    result += 1
  })

  assert_equal(50, result)

  var s0 = p0.Get()
  p0.Set(s0)

  assert_equal(50, result)
enddef

def Test_React_EffectRaisingException()
  var result = 0
  var counter = react.Property.new(1)
  const [Count, SetCount] = [counter.Get, counter.Set]

  tt.AssertFails(() => {
    react.CreateEffect(() => {
      result = Count()
      throw 'Aaaaargh!'
      result += 1 # Not executed
    })
  }, 'Aaaaargh!', 'AssertFails #0')

  react.CreateEffect(() => {
    # Dummy effect: this is here only to make sure that gActiveEffect has not
    # remained non-null after the previous effect has thrown an exception.
    })

  assert_equal(1, Count())
  assert_equal(1, len(counter.effects))
  assert_equal(1, result)

  tt.AssertFails(() => {
    SetCount(2)
  }, 'Aaaaargh!', 'AssertFails #1')

  assert_equal(2, Count())
  assert_equal(1, len(counter.effects))
  assert_equal(2, result)

  tt.AssertFails(() => {
    SetCount(Count() * 3)
  }, 'Aaaaargh!', 'AssertFails #2')

  assert_equal(6, Count(), 'Count() should be 6')
  assert_equal(1, len(counter.effects))
  assert_equal(6, result, 'result should be 6')
enddef

def Test_React_SetWithTimer()
  const [Count, SetCount] = GetSet(2)
  const [Multiplier, _] = GetSet(3)
  const Product = (): number => Count() * Multiplier()
  var result = 0

  react.CreateEffect(() => {
    result += Product()
  })

  react.CreateEffect(() => {
    result *= Count()
  })

  assert_equal(result, 12)

  timer_start(20, (_) => SetCount(Count() + 1), {repeat: 3})
  sleep 80m
  assert_equal(1575, result)
enddef

def Test_React_Effect()
  var flag = false
  const [Count, SetCount] = GetSet(2)
  const DoubleCount = (): number => {
    flag = !flag
    return Count() * 2
  }

  react.CreateEffect(() => {
    DoubleCount()
  })

  assert_true(flag)

  SetCount(-4)

  assert_false(flag)
  assert_equal(DoubleCount(), -8)
enddef

def Test_React_MultipleProperties()
  const [FirstName, SetFirstName] = GetSet('John')
  const [LastName, SetLastName] = GetSet('Smith')
  var name1 = ''
  var name2 = ''

  const FullName = (): string => {
    return $'{FirstName()} {LastName()}'
  }

  react.CreateEffect(() => {
    name1 = FullName()
  })

  react.CreateEffect(() => {
    name2 = FullName()
  })

  SetFirstName("Jacob")

  assert_equal('Jacob Smith', name1)
  assert_equal('Jacob Smith', name2)

  SetLastName('Doe')

  assert_equal('Jacob Doe', name1)
  assert_equal('Jacob Doe', name2)
enddef

def Test_React_CachedComputation()
  const [FirstName, SetFirstName] = GetSet('John')
  const [LastName, SetLastName] = GetSet('Smith')
  var run = 0
  var name = ''

  const FullName = react.ComputedProperty.new((): string => {
    ++run
    return $'{FirstName()} {LastName()}'
  })

  assert_equal(1, run) # The lambda is executed once upon creation
  assert_equal('John Smith', FullName.Get())
  assert_equal(1, run) # The name has been cached, so the lambda is not re-run

  react.CreateEffect(() => {
    name = FullName.Get()
  })

  assert_equal('John Smith', name) # The effect is initially run once
  assert_equal(1, run) # The name is cached, so the lambda is not re-run

  SetFirstName('Jacob')

  assert_equal('Jacob Smith', name)
  assert_equal(2, run) # The name has changed, the lambda has been re-run

  assert_equal('Jacob Smith', FullName.Get())
  assert_equal(2, run)

  SetLastName('Doe')

  assert_equal('Jacob Doe', name)
  assert_equal(3, run) # The name has changed, the lambda has been re-run

  assert_equal('Jacob Doe', FullName.Get())
  assert_equal(3, run)
enddef

def Test_React_FineGrainedReaction()
  const [FirstName, SetFirstName] = GetSet('John')
  const [LastName, SetLastName] = GetSet('Smith')
  const [ShowFullName, SetShowFullName] = GetSet(true)
  var name = ''
  var run = 0

  const DisplayName = react.ComputedProperty.new((): string => {
    ++run
    if !ShowFullName() # When ShowFullName() is false, only first name is tracked
      return FirstName()
    endif

    return $'{FirstName()} {LastName()}'
  }).Get

  assert_equal('John Smith', DisplayName())
  assert_equal(1, run)

  react.CreateEffect(() => {
    name = DisplayName()
  })

  assert_equal('John Smith', name) # Effect is executed once upon creation
  assert_equal(1, run) # But it reads the cached value, lambda is not run

  SetShowFullName(false) # Affects display name, recomputation needed

  assert_equal(2, run) # Display name changed, lambda re-run
  assert_equal('John', DisplayName())
  assert_equal(2, run) # DisplayName() used cached value
  assert_equal('John', name) # Effect has been triggered, too
  assert_equal(2, run) # Effect used cached value

  SetLastName("Legend") # No side effect because right now last name is not tracked

  assert_equal('John', DisplayName())
  assert_equal('John', name)
  assert_equal(2, run)

  SetShowFullName(true) # Affects display name, recomputation needed

  assert_equal(3, run) # Display name changed, lambda re-run
  assert_equal('John Legend', DisplayName())
  assert_equal(3, run)
  assert_equal('John Legend', name) # Effect has been triggered, too

  SetLastName("Denver") # Full name is now tracked, so side effect is triggered

  assert_equal(4, run) # Display name changed, lambda re-run
  assert_equal('John Denver', DisplayName())
  assert_equal(4, run)
  assert_equal('John Denver', name) # Effect has been triggered, too
  assert_equal(4, run)
enddef

def Test_React_EffectCascade()
  const [A, SetA] = GetSet(2)
  const [B, SetB] = GetSet(1)
  var result = -1

  react.CreateEffect(() => {
    result = B()
  })

  assert_equal(1, result)

  react.CreateEffect(() => {
    const a = A()
    SetB(a)
  })

  assert_equal(2, A())
  assert_equal(2, B())
  assert_equal(2, result)
enddef

def Test_React_EffectCascadeInverted()
  const [A, SetA] = GetSet(2)
  const [B, SetB] = GetSet(1)
  var result = -1

  assert_equal(2, A())
  assert_equal(1, B())

  react.CreateEffect(() => {
    const a = A()
    SetB(a)
  })

  assert_equal(2, A())
  assert_equal(A(), B())
  assert_equal(-1, result)

  react.CreateEffect(() => {
    result = B()
  })

  assert_equal(2, result)

  SetA(3)

  assert_equal(3, A())
  assert_equal(3, B())
  assert_equal(3, result)
enddef

def Test_React_SelfRecursionIsDetected()
  const [V1, SetV1] = GetSet(4)

  # The effect is bound to the signal because the effect's function reads the
  # signal. But then the effect would be recursively triggered when the signal
  # is updated.
  tt.AssertFails(() => {
    react.CreateEffect(() => {
      SetV1(V1() * 3)
    })
  }, 'recursive effects')
enddef

def Test_React_EffectTriggeringItselfWithoutChangingValue()
  var p1 = react.Property.new(7)

  # As the value is not changed, the effect is not triggered recursively.
  react.CreateEffect(() => {
    p1.Set(p1.Get())
  })

  assert_equal(7, p1.Get())

  # If, however, effects are forcefully triggered, this goes into an infinite
  # loop.
  tt.AssertFails(() => {
    react.CreateEffect(() => {
      p1.Set(p1.Get(), {'force': true})
    })
  }, 'recursive effects')
enddef

def Test_React_RecursiveEffectsAreDetected()
  const [V2, SetV2] = GetSet(3)
  const [V3, SetV3] = GetSet(5)

  tt.AssertFails(() => {
    react.CreateEffect(() => {
      SetV3(V2() + 1)
    })

    assert_equal(4, V3())

    react.CreateEffect(() => {
      SetV2(V3() - 2)
    })
  }, 'recursive effects')
enddef

def Test_React_CreateEffectInClass()
  var p0 = react.Property.new(4)
  var p1 = react.Property.new(5)
  var x0 = X.new(p0)
  var x1 = X.new(p1)

  p0.Set(7)
  p1.Set(9)

  assert_equal(7, p0.Get())
  assert_equal(7, x0.result)
  assert_equal(9, p1.Get())
  assert_equal(9, x1.result)
enddef

def Test_React_NestedEffects()
  var p0 = react.Property.new(0)
  var result = 0

  react.CreateEffect(() => { # E1
    p0.Set(2024)

    # E2
    react.CreateEffect(() => {
      result = p0.Get()
    })
  })

  assert_equal(2024, result)

  p0.Set(2025) # Triggers E2

  assert_equal(2025, result)
enddef

def Test_React_NestedEffectsInfiniteLoop()
  var p0 = react.Property.new(0)

  # E1 creates and executes E2, which will trigger E1 again, causing another
  # instance of E2 to be created, which will trigger E1 again, ad libitum.
  tt.AssertFails(() => {
    # E1
    react.CreateEffect(() => {
      var x = p0.Get()

      # E2
      react.CreateEffect(() => {
        p0.Set(x + 1)
      })
    })
  }, 'recursive effects', 'An infinite loop should have been detected')
enddef

def Test_React_NestedEffectUsingClass()
  var p0 = react.Property.new(80)
  var p1 = react.Property.new(91)

  def Init(p: react.Property): X
    var x: X

    react.CreateEffect(() => {
      x = X.new(p)
    })

    return x
  enddef

  var x0 = Init(p0)
  var x1 = Init(p1)

  assert_equal(80, x0.result)
  assert_equal(91, x1.result)

  p1.Set(99)
  p0.Set(88)

  assert_equal(88, x0.result)
  assert_equal(99, x1.result)
enddef

def Test_React_ConditionalNestedEffect()
  var flag   = react.Property.new(false)
  var result = 0
  var count  = 0

  def F(): number
    react.CreateEffect(() => { # E1
      ++result
      flag.Set(false)
      })
    return result + 2
  enddef

  react.CreateEffect(() => { # E2
    ++count
    if flag.Get()
      result = F()
    endif
  })

  assert_equal(1, count)
  assert_equal(0, result) # flag is false, F() was not called

  flag.Set(true) # Triggers E2, which calls F() to create E1

  assert_equal(3, count) # E2 is also triggered by flag.Set() in E1
  assert_false(flag.Get())
  assert_equal(3, result)
enddef

type View = func(): list<string>
type Reader = func(): any

def Test_React_VStack()
  const [V1, SetV1] = GetSet('a')
  const [V2, SetV2] = GetSet('b')
  const [V3, SetV3] = GetSet('b')
  const View1 = (): list<string> => [V1(), V2()]
  const View2 = (): list<string> => [V2(), V1()]

  def VStack(...views: list<View>): View
    var stacked: list<Reader>

    for V in views
      var memo = react.ComputedProperty.new(V) # Creates an effect that tracks V's signals
      stacked->add(memo.Get)
    endfor

    return (): list<string> => {
      var text: list<string> = []

      for R in stacked
        text->extend(R())
      endfor

      return text
    }
  enddef

  const MainView = VStack(View1, View2)
  var result: list<string> = []
  var n = 0

  react.CreateEffect(() => { # Tracks the two memo signals, *not* V1, V2 directly
    ++n
    result = MainView()
  })

  assert_equal(1, n)
  assert_equal(['a', 'b', 'b', 'a'], result)

  SetV1('x')
  assert_equal(['x', 'b', 'b', 'x'], result)
  assert_equal(2, n)

  SetV2('y')
  assert_equal(['x', 'y', 'y', 'x'], result)
  assert_equal(3, n)
enddef

def Test_React_EffectSimpleOrdering()
  const [V1, SetV1] = GetSet(0)
  var result = ''

  react.CreateEffect(() => {
    V1()
    result ..= 'A'
  })
  react.CreateEffect(() => {
    V1()
    result ..= 'B'
  })
  react.CreateEffect(() => {
    V1()
    result ..= 'C'
  })

  assert_equal('ABC', result)

  SetV1(1) # Effects are run in the order they were created

  assert_equal('ABCABC', result)
enddef

def Test_React_EffectOrdering()
  # Effects are executed as atomic units: this makes it easier to reason about
  # the code. The example below executes as if effects were run in the order
  # (1), (2), (3), (2). No interleaving among effects is possible.
  const [V1, SetV1] = GetSet(1)
  const [V2, SetV2] = GetSet(2)
  var result = ''
  var n = 0

  assert_equal(1, V1())
  assert_equal(2, V2())

  # (1)
  react.CreateEffect(() => {
    ++n
    SetV2(V1())
    result ..= 'A'
  })

  assert_equal(1, n)
  assert_equal(1, V1())
  assert_equal(1, V2())
  assert_equal('A', result)

  # (2)
  react.CreateEffect(() => {
    ++n
    V2()
    result ..= 'B'
  })

  assert_equal(2, n)
  assert_equal(1, V1())
  assert_equal(1, V2())
  assert_equal('AB', result)

  # (3)
  react.CreateEffect(() => {
    ++n
    # When updating a value inside an effect, its effects should be run
    # only once and only after this effect has run completely
    SetV2(V1() + 1)
    SetV2(-100)
    SetV2(V1() + 2)
    result ..= 'C'
  })

  assert_equal(4, n)
  assert_equal(1, V1())
  assert_equal(3, V2())
  assert_equal('ABCB', result)

  # Effects are run in the order they are created. The following update will
  # notify (1) then (3). Since they both update V2, also (2) is called (once)
  # after (1) and (3) have run to completion.
  # Note that the notifications are spawned in a breadth-first way: even if
  # (1) updates V2, the observers of V2 are notified only after (3) has run.
  # (A depth-first propagation would result in the sequence (1) (2) (3) (2),
  # with (2) executed twice).
  SetV1(5)

  assert_equal(7, n)
  assert_equal(5, V1())
  assert_equal(7, V2())
  assert_equal('ABCBACB', result)
enddef

def Test_React_NotRecursive()
  const [V1, SetV1] = GetSet(1)
  const [V2, SetV2] = GetSet(2)
  var sequence = ''

  react.CreateEffect(() => { # Observes V1
    sequence ..= 'A'
    V1()
  })

  assert_equal('A', sequence)

  react.CreateEffect(() => { # Observes V2
    sequence ..= 'B'
    SetV1(V2())
  })

  assert_equal(2, V1())
  assert_equal(2, V2())
  assert_equal('ABA', sequence)

  react.CreateEffect(() => { # Observes V2
    sequence ..= 'C'
    SetV1(9)
    SetV2(7)
  })

  assert_equal(7, V1())
  assert_equal(7, V2())
  assert_equal('ABACABA', sequence)
enddef

def Test_React_NotRecursiveTransaction()
  const [V1, SetV1] = GetSet(1)
  const [V2, SetV2] = GetSet(2)
  var sequence = ''

  react.Transaction(() => {
    react.CreateEffect(() => {
      sequence ..= 'A'
      V1()
    })

    assert_equal('A', sequence)

    react.CreateEffect(() => {
      sequence ..= 'B'
      SetV1(V2())
    })

    assert_equal(2, V1())
    assert_equal(2, V2())
    assert_equal('AB', sequence)

    react.CreateEffect(() => {
      sequence ..= 'C'
      SetV1(9)
      SetV2(7)
    })

    assert_equal(9, V1())
    assert_equal(7, V2())
    assert_equal('ABC', sequence)
  })

  assert_equal(7, V1())
  assert_equal(7, V2())
  assert_equal('ABCABA', sequence)
enddef

def Test_React_EffectString()
  var property = react.Property.new('a')
  var result = ''

  react.CreateEffect(() => {
    result = property.Get()
  })
  const effects = property.effects

  assert_equal('a', result)
  assert_equal(1, len(effects))
  assert_match('<lambda>\d\+', string(effects[0]))
enddef

def Test_React_PropertyString()
  var property = react.Property.new('the value')

  react.CreateEffect(() => {
    property.Get()
  })
  react.CreateEffect(() => {
    property.Get()
  })

  assert_equal('the value', string(property))
enddef

def Test_React_Pool()
  var pool: list<react.Property> = []
  var result = ''
  var p0 = react.Property.new('o', {pool: pool})

  assert_equal(1, len(pool))

  def F(): react.Property
    var p1 = react.Property.new('n', {pool: pool})

    react.CreateEffect(() => {
      result ..= p1.Get()
    })

    return p1
  enddef

  var pf = F()

  assert_equal(2, len(pool))
  assert_equal('n', pf.Get())
  assert_equal('n', result)

  react.CreateEffect(() => {
    result ..= p0.Get()
    pf.Set('w')
  })

  assert_equal('now', result)

  for p in pool # Clear effects
    p.ClearEffects()
  endfor
  p0.Set('he')
  pf.Set('re')

  assert_equal('now', result)
enddef

def Test_React_PropertyInsideFunction()
  var result = ''
  var pool: list<react.Property> = []
  const F = (): react.Property => {
    var p = react.Property.new('a', {pool: pool})

    react.CreateEffect(() => {
      result ..= p.Get()
    })

    return p
  }
  var q = F()

  assert_equal(1, len(pool))
  assert_true(pool[0] is q)

  q.Set('b')

  assert_equal('ab', result)

  pool[0].ClearEffects()
  q.Set('c')

  assert_equal('ab', result)
enddef


def Test_React_TwoEffectsOneLambda()
  var p = react.Property.new('x')
  var result = ''

  const F = () => {
    result ..= p.Get()
  }

  react.CreateEffect(F)
  react.CreateEffect(F)
  p.Set('y')

  assert_equal(2, len(p.effects))
  assert_equal(p.effects[0], p.effects[1]) # Two effects, but same lambda
  assert_true(p.effects[0] isnot p.effects[1])
  assert_equal('xxyy', result)
enddef


def Test_React_ReuseLambda()
  var p = react.Property.new('x')
  var result = ''

  const F = () => {
    result ..= p.Get()
  }

  const E = () => {
    react.CreateEffect(F)
  }

  E()

  assert_equal('x', result)
  assert_equal(1, len(p.effects))

  p.Set('y')

  assert_equal('xy', result)
  assert_equal(1, len(p.effects))

  E()

  assert_equal('xyy', result)
  assert_equal(2, len(p.effects))
  assert_equal(p.effects[0], p.effects[1])

  p.Set('z')

  assert_equal('xyyzz', result)
  assert_equal(2, len(p.effects))
  assert_equal(p.effects[0], p.effects[1])
  assert_false(p.effects[0] is p.effects[1])

  p.ClearEffects()
  E()
  assert_equal('xyyzzz', result)
  assert_equal(1, len(p.effects))
enddef

def Test_React_TransactionEffects()
  # This is an example from the help file
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    result = p1.Get()
  })

  react.Transaction(() => {
    p1.Set(1)
    p2.Set(2)
  })

  assert_equal(2, p1.Get())
  assert_equal(2, p2.Get())
  assert_equal(2, result)
enddef

def Test_React_TransactionEffectsBis()
  # This is an example from the help file
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    result = p1.Get()
  })

  react.Transaction(() => {
    p1.ClearEffects()
    p1.Set(1)
    p2.Set(2)
  })

  assert_equal(2, p1.Get())
  assert_equal(2, p2.Get())
  assert_equal(0, result)
enddef

def Test_React_TransactionEffectsTer()
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    result = p1.Get()
  })

  react.Transaction(() => {
    p1.Set(1)
    p2.ClearEffects()
    p2.Set(2)
  })

  assert_equal(1, p1.Get())
  assert_equal(2, p2.Get())
  assert_equal(1, result)
enddef

def Test_React_TransactionEffectsQuater()
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    result = p1.Get()
  })

  react.Transaction(() => {
    p2.Set(2)
    p1.Set(1)
  })

  assert_equal(2, p1.Get())
  assert_equal(2, p2.Get())
  assert_equal(2, result)
enddef

def Test_React_TwoValuesCanTrackEachOther()
  # This works because no effect is triggered if Set() does not change the
  # current value.
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    p2.Set(p1.Get())
  })

  p1.Set(1)

  assert_equal(1, p1.Get())
  assert_equal(p2.Get(), p1.Get())

  p2.Set(2)

  assert_equal(2, p2.Get())
  assert_equal(p2.Get(), p1.Get())

  p1.Set(p2.Get() + 1)

  assert_equal(3, p1.Get())
  assert_equal(p2.Get(), p1.Get())
enddef

def Test_React_PropertyIsAlwaysDoubleOfAnother()
  var p1 = react.Property.new(1.0)
  var p2 = react.Property.new(2.0)

  react.CreateEffect(() => { # Effect 1
    p1.Set(p2.Get() / 2.0)
  })

  react.CreateEffect(() => { # Effect 2
    p2.Set(p1.Get() * 2.0)
  })

  p1.Set(5.0)

  assert_equal(5.0, p1.Get())
  assert_equal(10.0, p2.Get())

  p2.Set(p1.Get() * 5.0)

  assert_equal(25.0, p2.Get())
  assert_equal(12.5, p1.Get())
enddef

def Test_React_Cache()
  var p0 = react.Property.new(2)

  const F = (): number => {
    return p0.Get() * p0.Get()
  }

  const c0 = react.ComputedProperty.new(F)

  assert_equal(4, c0.Get())

  p0.Set(3)

  assert_equal(9, c0.Get())
enddef

def Test_React_ComputedProperty()
  var p0 = react.Property.new(2)
  var c0 = react.ComputedProperty.new(() => p0.Get() * 2)

  assert_equal(4, c0.Get())

  p0.Set(5)

  assert_equal(10, c0.Get())
enddef

def Test_React_ComputedObject()
  var d0 = Dummy.new(1)
  var d1 = Dummy.new(2)
  var d2 = Dummy.new(2)
  var p0 = react.Property.new(d0)
  var c0 = react.ComputedProperty.new(() => p0.Get(), {'force': true})

  assert_notequal(d0, d1)
  assert_true(d0 isnot d1)
  assert_equal(d1, d2)
  assert_true(d1 isnot d2)

  assert_equal(p0.Get(), c0.Get())
  assert_true(p0.Get() is c0.Get())
  assert_true(c0.Get() is d0)

  p0.Set(d1)

  assert_equal(p0.Get(), c0.Get())
  assert_true(p0.Get() is c0.Get())
  assert_true(c0.Get() is d1)

  p0.Set(d2) # As Set() uses == this will not change the object

  assert_equal(p0.Get(), c0.Get())
  assert_true(p0.Get() is c0.Get())
  assert_true(c0.Get() is d1)
  assert_true(c0.Get() isnot d2)

  p0.Set(d2, {force: true})

  assert_equal(p0.Get(), c0.Get())
  assert_true(p0.Get() is c0.Get())
  assert_true(c0.Get() isnot d1)
  assert_true(c0.Get() is d2)
enddef

def Test_React_ComputedPropertyCannotBeSet()
  var p0 = react.Property.new(42)
  var c0 = react.ComputedProperty.new(() => p0.Get() + 1)

  tt.AssertFails(() => {
    c0.Set(2)
  }, 'cannot be set')
enddef

def Test_React_ListProperty()
  var l0 = react.Property.new([])
  var result = ''

  react.CreateEffect(() => {
    var items = l0.Get()
    result ..= join(items, '')
  })

  var value: list<string> = l0.Get() # Obtain value by reference

  for ch in ['A', 'B', 'C']
    value->add(ch)
    l0.Set(value, {force: true}) # true necessary to trigger effects
  endfor

  assert_equal(['A', 'B', 'C'], l0.Get())
  assert_equal('AABABC', result)


  for ch in ['D', 'E', 'F']
    value = copy(l0.Get()) # This must be inside the transaction
    value->add(ch)
    l0.Set(value) # true not needed as we are acting on a copy
  endfor

  assert_equal(['A', 'B', 'C', 'D', 'E', 'F'], l0.Get())
  assert_equal('AABABCABCDABCDEABCDEF', result)
enddef

def Test_React_ComputedPropertyWithPool()
  var pool: list<react.Property> = []
  var p0 = react.Property.new(3)
  var c0 = react.ComputedProperty.new(() =>  2 * p0.Get(), {pool: pool})

  assert_equal(1, len(pool))
  assert_equal(6, c0.Get())

  p0.Set(21)

  assert_equal(42, c0.Get())
enddef

def Test_React_ListPropertyTransaction()
  var l0 = react.Property.new([])
  var result = ''

  react.CreateEffect(() => {
    var items = l0.Get()
    result ..= join(items, '')
  })

  var value: list<string> = l0.Get() # Obtain value by reference

  react.Transaction(() => {
    for ch in ['A', 'B', 'C']
      value->add(ch)
      l0.Set(value, {force: true}) # true necessary to trigger effects
    endfor
  })

  assert_equal(['A', 'B', 'C'], l0.Get())
  assert_equal('ABC', result)

  value = copy(l0.Get())

  react.Transaction(() => {
    for ch in ['D', 'E', 'F']
      value->add(ch)
      l0.Set(value) # true not needed
    endfor
  })

  assert_equal(['A', 'B', 'C', 'D', 'E', 'F'], l0.Get())
  assert_equal('ABCABCDEF', result)
enddef



def Test_React_SpecializedProperty()
  var pool: list<react.Property> = []
  var p0 = react.Property.new(25, {pool: pool})
  var c0 = ChildProperty.new('x', {pool: pool})
  var result = ''

  assert_equal([p0, c0], pool)
  assert_equal('25', string(p0))
  assert_equal('x', string(c0))

  var n = str2nr(matchstr(string(p0), '\d\+'))

  assert_equal('x', string(c0))
  assert_equal(0, len(c0.effects))

  react.CreateEffect(() => {
    result = c0.Get()
  })

  c0.Set('y')

  assert_equal('x', c0.Get())
  assert_equal('x', result)

  c0.Set('y', {force: true})

  assert_equal('xy', c0.Get())
  assert_equal('xy', result)
enddef

def Test_React_RollbackEffect()
  var r0: list<dict<number>> = []
  var logged = react.Property.new([])
  var counter = 0

  def Rollback()
    for t in logged.Get()
      r0->remove(index(r0, t))
    endfor
  enddef

  def Insert(t: dict<number>)
    r0->add(t)
    var inserted = logged.Get()
    inserted->add(t)
    logged.Set(inserted, {force: true})
  enddef

  react.CreateEffect(() => { # Effect 1
    for t in logged.Get()
      if t.A == 5
        Rollback()
        react.Reset()
      endif
    endfor
  })

  react.CreateEffect(() => { # Effect 2
    for t in logged.Get()
      ++counter
    endfor
  })

  react.Transaction(() => {
    Insert({A: 1})
    Insert({A: 2})
    Insert({A: 3})
  })

  assert_equal([{A: 1}, {A: 2}, {A: 3}], r0)
  assert_equal([{A: 1}, {A: 2}, {A: 3}], logged.Get())
  assert_equal(3, counter)

  logged.Set([])

  assert_equal([{A: 1}, {A: 2}, {A: 3}], r0)
  assert_true(empty(logged.Get()))
  assert_equal(3, counter)

  react.Transaction(() => {
    Insert({A: 4})

    # The following Insert() causes this transaction to be undone upon commit
    # by Effect 1. Since Effect 1 resets the effects' queue, Effect 2 is not
    # executed.
    Insert({A: 5})
    Insert({A: 6})
  })

  assert_equal([{A: 1}, {A: 2}, {A: 3}], r0)
  assert_equal([{A: 4}, {A: 5}, {A: 6}], logged.Get())
  assert_equal(3, counter)
enddef

def Test_React_EffectDefaultPriority()
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0
  var count  = 0

  react.CreateEffect(() => { # Effect 1
    ++count
    p1.Set(p2.Get())
  })

  react.CreateEffect(() => { # Effect 2
    ++count
    result = p1.Get()
  })

  count = 0

  react.Transaction(() => {
    p1.Set(1)  # Enqueues effect 2
    p2.Set(2)  # Enqueues effect 1
  })

  # At commit time, effect 2 and effect 1 are executed (in this order),
  # but effect 1 pushes effect 2 in the queue again.
  assert_equal(2, result)
  assert_equal(3, count)
enddef

def Test_React_EffectCustomPriority()
  var p1 = react.Property.new(0)
  var p2 = react.Property.new(0)
  var result = 0
  var count  = 0

  react.CreateEffect(() => { # Effect 1
    ++count
    p1.Set(p2.Get())
  }, {weight: 1})

  react.CreateEffect(() => { # Effect 2
    ++count
    result = p1.Get()
  }, {weight: 2})

  count = 0

  react.Transaction(() => {
    p1.Set(1)  # Enqueues effect 2
    p2.Set(2)  # Enqueues effect 1, but puts it first
  })

  # At commit time, effect 1 must execute before effect 2
  assert_equal(2, result)
  assert_equal(2, count)
enddef

def Test_React_ManualEffectExecution()
  var p0 = react.Property.new(1)
  var result = 0

  var effect = react.CreateEffect(() => {
    result = p0.Get() + 1
  }, {execute: false})

  assert_equal(0, result)
  assert_equal([], effect.dependentProperties)
  assert_equal([], p0.effects)

  p0.Set(2) # Doesn't trigger the effect because it was never executed

  assert_equal(0, result)
  assert_equal([], effect.dependentProperties)

  # Manually register the effect as an observer of p0
  p0.Register(effect)

  assert_equal(0, result)
  assert_equal([p0], effect.dependentProperties)
  assert_equal([effect], p0.effects)

  p0.Set(3)

  assert_equal(4, result)
  assert_equal([p0], effect.dependentProperties)
enddef


tt.Run('_React_')

