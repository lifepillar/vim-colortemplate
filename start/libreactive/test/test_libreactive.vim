vim9script

import 'libtinytest.vim'           as tt
import '../import/libreactive.vim' as react

def GetSet(value: any): list<func>
  var p = react.Property.new(value)
  return [p.Get, p.Set]
enddef

def Test_React_SimpleProperty()
  var cnt = react.Property.new(2)
  const DoubleCount = () => cnt.Get() * 2

  assert_equal(DoubleCount(), 4)

  cnt.Set(3)

  assert_equal(DoubleCount(), 6)

  cnt.Set(cnt.Get() + 2)

  assert_equal(DoubleCount(), 10)
enddef

def Test_React_SimpleEffect()
  var result = 0
  const [Count, SetCount] = GetSet(1)

  react.CreateEffect(() => {
    result = Count()
  })

  assert_equal(1, result)

  SetCount(2)

  assert_equal(2, result)

  SetCount(Count() * 3)

  assert_equal(6, result)
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

  const FullName = react.CreateMemo((): string => {
    ++run
    return $'{FirstName()} {LastName()}'
  })

  assert_equal(1, run) # The lambda is executed once upon creation
  assert_equal('John Smith', FullName())
  assert_equal(1, run) # The name has been cached, so the lambda is not re-run

  react.CreateEffect(() => {
    name = FullName()
  })

  assert_equal('John Smith', name) # The effect is initially run once
  assert_equal(1, run) # The name is cached, so the lambda is not re-run

  SetFirstName('Jacob')

  assert_equal('Jacob Smith', name)
  assert_equal(2, run) # The name has changed, the lambda has been re-run

  assert_equal('Jacob Smith', FullName())
  assert_equal(2, run)

  SetLastName('Doe')

  assert_equal('Jacob Doe', name)
  assert_equal(3, run) # The name has changed, the lambda has been re-run

  assert_equal('Jacob Doe', FullName())
  assert_equal(3, run)
enddef

def Test_React_FineGrainedReaction()
  const [FirstName, SetFirstName] = GetSet('John')
  const [LastName, SetLastName] = GetSet('Smith')
  const [ShowFullName, SetShowFullName] = GetSet(true)
  var name = ''
  var run = 0

  const DisplayName = react.CreateMemo((): string => {
    ++run
    if !ShowFullName() # When ShowFullName() is false, only first name is tracked
      return FirstName()
    endif

    return $'{FirstName()} {LastName()}'
  })

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

def Test_React_NestedCreateEffectIsAnError()
  tt.AssertFails(() => {
    react.CreateEffect(() => {
      react.CreateEffect(() => {
        })
    })
  }, 'Nested CreateEffect()')
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
      const VRead: Reader = react.CreateMemo(V) # Creates an effect that tracks V's signals
      stacked->add(VRead)
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
    # When updating a value inside an effect, its effects should be updated
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
  const effects = property.Effects()

  assert_equal('a', result)
  assert_equal(1, len(effects))
  assert_match('<lambda>\d\+', effects[0])
enddef

def Test_React_PropertyInsideFunction()
  var result = ''
  const F = (): react.Property => {
    var p = react.Property.new('a', 'FOO')

    react.CreateEffect(() => {
      result ..= p.Get()
    })

    return p
  }
  var q = F()
  q.Set('b')

  assert_equal('ab', result)

  react.Clear('FOO')
  q.Set('c')

  assert_equal('ab', result)
enddef


tt.Setup = () => {
  react.Reinit() # Reset libreactive's internal state
}
tt.Teardown = () => {
  react.Clear('', true) # Clean up after each test
}

tt.Run('_React_')

