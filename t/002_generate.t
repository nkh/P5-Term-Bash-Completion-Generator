# test

use strict ;
use warnings ;

use Test::Exception ;
use Test::Warn;
use Test::NoWarnings qw(had_no_warnings);

use Test::More 'no_plan';
#use Test::UniqueTestNames ;

use Test::Block qw($Plan);

use Term::Bash::Completion::Generator ;
use Text::Diff ;

{
local $Plan = {'generate_perl_completion_function' => 7} ;

my $expected_perl_script = <<'EOF' ;
#! /usr/bin/perl

=pod

Add the following line in your I<~/.bashrc> or B<source> them:

_my_command_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command_perl_completion my_command

Replace I<my_command_perl_completion_script> with the name you saved the script under. The script has to
be executable and somewhere in the path.

I<Arguments> received from bash:

=over 2

=item * $index - index of the command line argument to complete (starting at '1')

=item * $command - a string containing the command name

=item * \@argument_list - list of the arguments typed on the command line

=back

You return possible completion you want separated by I<\n>. Return nothing if you
want the default bash completion to be run which is possible because of the <-o defaul>
passed to the B<complete> command.

Note! You may have to re-run the B<complete> command after you modify your perl script.

=cut

use strict;
use Tree::Trie;

my @completions =
	qw(
	--aeode
	--calliope
	--clio
	--erato
	--euterpe
	--melete
	--melpomene
	--mneme
	--polymnia
	--terpsichore
	--thalia
	--urania
	) ;

my($trie) = new Tree::Trie;
$trie->add(@completions) ;

my ($argument_index, $command, @arguments) = @ARGV ;

$argument_index-- ;
my $word_to_complete = $arguments[$argument_index] ;

if(defined $word_to_complete)
	{
	my @possible_completions = $trie->lookup($word_to_complete) ;
	print join("\n", @possible_completions) ;
	}
#~ else
	#~ {
	#~ # give all the possible completions, this would override other bash completion mechanisms (path, ...)
	#~ print join("\n", $trie->lookup('')) ;
	#~ }
EOF

my $expected_bash_command = <<'EOF' ;
_my_command_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command_perl_completion my_command
EOF

my ($bash_command, $perl_script) = 
	Term::Bash::Completion::Generator::generate_perl_completion_script('my_command') ;

is($bash_command, $expected_bash_command, 'generated command matches') #;
	or diag (diff(\$bash_command, \$expected_bash_command)) ; 

is($perl_script, $expected_perl_script, 'generated script matches')  #;
	or diag (diff(\$perl_script, \$expected_perl_script)) ; 

#-------------------------------------------------------------------------------------------------

my $expected_perl_script2 = <<'EOF' ;
#! /usr/bin/perl

=pod

Add the following line in your I<~/.bashrc> or B<source> them:

_my_command2_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command2_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command2_perl_completion my_command2

Replace I<my_command2_perl_completion_script> with the name you saved the script under. The script has to
be executable and somewhere in the path.

I<Arguments> received from bash:

=over 2

=item * $index - index of the command line argument to complete (starting at '1')

=item * $command - a string containing the command name

=item * \@argument_list - list of the arguments typed on the command line

=back

You return possible completion you want separated by I<\n>. Return nothing if you
want the default bash completion to be run which is possible because of the <-o defaul>
passed to the B<complete> command.

Note! You may have to re-run the B<complete> command after you modify your perl script.

=cut

use strict;
use Tree::Trie;

my @completions =
	qw(
	-j
	--jobs
	-d
	--display_documentation
	-o
	) ;

my($trie) = new Tree::Trie;
$trie->add(@completions) ;

my ($argument_index, $command, @arguments) = @ARGV ;

$argument_index-- ;
my $word_to_complete = $arguments[$argument_index] ;

if(defined $word_to_complete)
	{
	my @possible_completions = $trie->lookup($word_to_complete) ;
	print join("\n", @possible_completions) ;
	}
#~ else
	#~ {
	#~ # give all the possible completions, this would override other bash completion mechanisms (path, ...)
	#~ print join("\n", $trie->lookup('')) ;
	#~ }
EOF

my $expected_bash_command2 = <<'EOF' ;
_my_command2_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command2_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command2_perl_completion my_command2
EOF

my ($bash_command2, $perl_script2) = 
	Term::Bash::Completion::Generator::generate_perl_completion_script
		(
		'my_command2',
		['j|jobs=i', 'd|display_documentation:s', 'o'],
		) ;

is($bash_command2, $expected_bash_command2, 'generated command 2 matches') #;
	or diag (diff(\$bash_command2, \$expected_bash_command2)) ; 
	
is($perl_script2, $expected_perl_script2, 'generated script 2 matches') #;
	or diag (diff(\$perl_script2, \$expected_perl_script2)) ; 

#-------------------------------------------------------------------------------------------------

my $expected_perl_script3 = <<'EOF' ;
#! /usr/bin/perl

=pod

Add the following line in your I<~/.bashrc> or B<source> them:

_my_command3_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command3_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command3_perl_completion my_command3

Replace I<my_command3_perl_completion_script> with the name you saved the script under. The script has to
be executable and somewhere in the path.

I<Arguments> received from bash:

=over 2

=item * $index - index of the command line argument to complete (starting at '1')

=item * $command - a string containing the command name

=item * \@argument_list - list of the arguments typed on the command line

=back

You return possible completion you want separated by I<\n>. Return nothing if you
want the default bash completion to be run which is possible because of the <-o defaul>
passed to the B<complete> command.

Note! You may have to re-run the B<complete> command after you modify your perl script.

=cut

use strict;
use Tree::Trie;

my @completions =
	qw(
	-j
	--j
	-jobs
	--jobs
	-d
	--d
	-display_documentation
	--display_documentation
	-o
	--o
	) ;

my($trie) = new Tree::Trie;
$trie->add(@completions) ;

my ($argument_index, $command, @arguments) = @ARGV ;

$argument_index-- ;
my $word_to_complete = $arguments[$argument_index] ;

if(defined $word_to_complete)
	{
	my @possible_completions = $trie->lookup($word_to_complete) ;
	print join("\n", @possible_completions) ;
	}
#~ else
	#~ {
	#~ # give all the possible completions, this would override other bash completion mechanisms (path, ...)
	#~ print join("\n", $trie->lookup('')) ;
	#~ }
EOF

my $expected_bash_command3 = <<'EOF' ;
_my_command3_perl_completion()
{
local old_ifs="${IFS}"
local IFS=$'\n';
COMPREPLY=( $(my_command3_perl_completion.pl ${COMP_CWORD} ${COMP_WORDS[@]}) );
IFS="${old_ifs}"

return 1;
}

complete -o default -F _my_command3_perl_completion my_command3
EOF

my ($bash_command3, $perl_script3) = 
	Term::Bash::Completion::Generator::generate_perl_completion_script
		(
		'my_command3',
		['j|jobs=i', 'd|display_documentation:s', 'o'],
		1, # both single and double dash
		) ;

is($bash_command3, $expected_bash_command3, 'generated command 3 matches') #;
	or diag (diff(\$bash_command3, \$expected_bash_command3)) ; 
	
is($perl_script3, $expected_perl_script3, 'generated script 3 matches') #;
	or diag (diff(\$perl_script3, \$expected_perl_script3)) ; 

#------------------------------------------------------------------------------------------------------------------

throws_ok
	{
	Term::Bash::Completion::Generator::generate_perl_completion_script() ;
	}
	qr/Argument "\$command" not defined/, 'command needed' ;
}


{
local $Plan = {'generate_bash_completion_function' => 4} ;

my $completion_function = 
	Term::Bash::Completion::Generator::generate_bash_completion_function
		(
		'my_command',
		[qw( a bb ccc)],
		) ;

is($completion_function, <<'EOF', 'generated function matches') ;
_my_command_bash_completion()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '\
			-a --a \
			-bb --bb \
			-ccc --ccc \
			' -- $cur ) )
	fi

	return 0
}

complete -F _my_command_bash_completion -o default my_command
EOF

my $completion_function2 = 
	Term::Bash::Completion::Generator::generate_bash_completion_function
		(
		'my_command',
		['j|jobs=i', 'd|display_documentation:s', 'o'],
		) ;

is($completion_function2, <<'EOF', 'getopt argv options') ;
_my_command_bash_completion()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '\
			-j --j \
			-jobs --jobs \
			-d --d \
			-display_documentation --display_documentation \
			-o --o \
			' -- $cur ) )
	fi

	return 0
}

complete -F _my_command_bash_completion -o default my_command
EOF

my $completion_function3 = 
	Term::Bash::Completion::Generator::generate_bash_completion_function
		(
		'my_command',
		['j|jobs=i', 'd|display_documentation:s', 'o'],
		'COMPLETION_PREFIX',
		0, # single_and_double_dash
		'COMPLETE_OPTIONS'
		) ;

is($completion_function3, <<'EOF', 'generation options') ;
_my_command_bash_completion()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	if [[ "$cur" == COMPLETION_PREFIX ]]; then
		COMPREPLY=( $( compgen -W '\
			-j \
			--jobs \
			-d \
			--display_documentation \
			-o \
			' -- $cur ) )
	fi

	return 0
}

complete -F _my_command_bash_completion COMPLETE_OPTIONS my_command
EOF

throws_ok
	{
	Term::Bash::Completion::Generator::generate_bash_completion_function() ;
	}
	qr/Argument "\$command" not defined/, 'command needed' ;
	
=pod

the completion is accepted by source
the completion works

=cut
}
