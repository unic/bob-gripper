$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get rubble pattern" {
  Context "replacements" {
    $pattern = Get-RubblePattern 'Demo;;Before$Demo2After' @{"Demo"= "Replaced"; '$Demo2'= "Replaced2"}
    
    It "Should have removed entries" {
      $pattern.Count | Should Be 2
    }
    It "Should have replaced demo" {
      $pattern[0] | Should Be "Replaced"
    }

    It "Should have replaced demo2" {
      $pattern[1] | Should Be "BeforeReplaced2After"
    }
  }
  Context "iterated replacements" {
    $pattern = Get-RubblePattern '$role.$environment;$role;$environment' @{'$environment'= "test"; '$role'= @("role1","role2")}
    
    It "should have 7 possibilities" {
        $pattern.Count | Should be 7
    }
    
    It "Should have replaced role and env" {
      $pattern[0] | Should Be "role1.test"
      $pattern[1] | Should Be "role1.role2.test"
      $pattern[2] | Should Be "role2.test"
      $pattern[3] | Should Be "role1"
      $pattern[4] | Should Be "role1.role2"
      $pattern[5] | Should Be "role2"
      
    }
  }
}
