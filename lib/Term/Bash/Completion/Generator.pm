
package Term::Bash::Completion::Generator ;

use strict;
use warnings ;
use Carp qw(carp croak confess) ;

BEGIN 
{
use Sub::Exporter -setup => 
	{
	exports => [ qw() ],
	groups  => 
		{
		all  => [ qw() ],
		}
	};
	
use vars qw ($VERSION);
$VERSION     = '0.03';
}

#-------------------------------------------------------------------------------

=head1 NAME

Term::Bash::Completion::Generator - Generate bash completion scripts

=head1 SYNOPSIS

  # use default bash completion options
  generate_bash_completion_function('my_command', ['option1', ''option2']) ;
	
  # fine tune with the bash completion options
  generate_bash_completion_function('my_command', ['option1', ''option2'], '-*', 0, '-o plusdirs')

=head1 DESCRIPTION

Generate bash completion functions or perl scripts to provide completion for an application.

=head1 DOCUMENTATION

If you application or scripts have more than one or two options and you run a bash shell, it is 
advisable you provide a completion file for your application.

A completion file provides information to bash so when your user presses [tab], on the command line,
possible completion is provided to the user. 

This module provide you with subroutines to create the completion scripts. The completion scripts are
either simple bash functions or a perl script that allow you to dynamically generate completion. This
module generate scripts that are written in perl. 

The perl scripts can be generated  by calling the subroutine in this module or by running
the I<generate_perl_completion_script> script installed with this module.

The generated scripts can provide completion for applications written in any language. A good place to
generate completion is in your I<Build.PL> or I<Makefile.PL>. Remember to test your completions too.

=head1 BASH COMPLETION DOCUMENTATION

Run 'man bash' on your prompt and search for 'Programmable Completion'.

=head1 ADVANCED EXAMPLE

The generated perl script is a skeleton you can build your completion on. It will be enough for most
applications. You can look at the I<dynamic_completion.pl> example, found in this distribution, for a
more advance example.

L<http://khemir.net/http_share/completion.ogg.ogv> a soundless screencast of the example.

=head1 SUBROUTINES/METHODS

=cut


#-------------------------------------------------------------------------------

sub generate_perl_completion_script
{

=head2 generate_perl_completion_script($command, \@completion_list, $single_and_double_dash)

Generates a perl script that can be used to dynamically generate completion for the bash 
command line.

L<Tree::Trie> is used in the script to do the basic look-up. L<Tree::Trie> was installed as
dependency to this module. Modify the generated script to implement your completion logic.

You can also use the I<generate_perl_completion_script> script to create the perl completion
script from the command line.

I<Arguments>

=over 2 

=item * $command - a string containing the command name

=item * \@completion_list - list of options to create completion for

=item * $single_and_double_dash - boolean variable ; default is 1

0 - single dash for single letter options, double dash for multiple letters options
1 - all options have single and double dash

the options can be simple strings or a L<Getopt::Long> specifications 

=back

I<Returns> - an array containing:

=over 2 

=item * a string containing the bash completion command

=item * a string containing the perl script

=back

I<Exceptions> - carps if $command is not defined

=cut

my ($command, $completion_list, $single_and_double_dash) = @_ ;

croak 'Argument "$command" not defined' unless defined $command ; ## no critic ValuesAndExpressions::RequireInterpolationOfMetachars

my $bash_completion_command = <<"EOC" ;
_${command}_perl_completion()
{
local old_ifs="\${IFS}"
local IFS=\$'\\n';
COMPREPLY=( \$(${command}_perl_completion.pl \${COMP_CWORD} \${COMP_WORDS[@]}) );
IFS="\${old_ifs}"

return 1;
}

complete -o default -F _${command}_perl_completion $command
EOC

my $perl_completion_script = <<"EOC" ;
#! /usr/bin/perl

=pod

Add the following line in your I<~/.bashrc> or B<source> them:

$bash_completion_command
Replace I<${command}_perl_completion_script> with the name you saved the script under. The script has to
be executable and somewhere in the path.
EOC

$perl_completion_script .= <<'EOC' ;

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
EOC

if(defined $completion_list)
	{
	$completion_list = de_getop_ify_list($completion_list) ;
	}
else
	{
	$completion_list = [qw(aeode calliope clio erato euterpe melete melpomene mneme polymnia terpsichore thalia urania)]
	}

for my $option (@{$completion_list})
	{
	if($single_and_double_dash)
		{
		$perl_completion_script .= "\t-$option\n" ;
		$perl_completion_script .= "\t--$option\n" ;
		}
	else
		{
		if(1 == length($option))
			{
			$perl_completion_script .= "\t-$option\n" ;
			}
		else
			{
			$perl_completion_script .= "\t--$option\n" ;
			}
		}
	}
	
$perl_completion_script .= <<'EOC' ;
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
EOC

return($bash_completion_command, $perl_completion_script) ;
}

sub generate_bash_completion_function
{

=head2 generate_bash_completion_function($command, \@completion_list, $completion_prefix, $single_and_double_dash, $complete_options)

Generates a bash function that provides completion for the options passed as parameter.
The options can be simple strings like 'output_directory' or 'a' or L<Getopt::Long> specifications 
like 'j|jobs=i', 'd|display_documentation:s', or 'o'.

Note that the options do not have any dash at the start.

I<Arguments>

=over 2 

=item * $command - a string containing the command name

=item * \@completion_list - list of options to create completion for

the options can be simple strings or a L<Getopt::Long> specifications 

=item * $completion_prefix - see bash manual ; default is '-*'

=item * $single_and_double_dash - boolean variable ; default is 1

0 - single dash for single letter options, double dash for multiple letters options
1 - all options have single and double dash

=item * $complete_options - string containing the options passed to I<complete> ; default is '-o default'

=back

I<Returns> - a string containing the bash completion script

I<Exceptions> - carps if $command is not defined

=cut

my ($command, $completion_list, $completion_prefix, $single_and_double_dash, $complete_options) = @_ ;

croak 'Argument "$command" not defined' unless defined $command ; ## no critic ValuesAndExpressions::RequireInterpolationOfMetachars

$completion_prefix = q{-*} unless defined $completion_prefix ;
$single_and_double_dash = 1 unless defined $single_and_double_dash ;
$complete_options = '-o default' unless defined $complete_options ;

my $completion_function_name = "_${command}_bash_completion" ;
$completion_function_name =~ s/[^a-zA-Z0-9_]/_/gsmx ;

my $completion_function = "$completion_function_name()\n" ;

$completion_function .= <<'EOH' ;
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
EOH

$completion_function .= <<"EOH" ;
	if [[ "\$cur" == $completion_prefix ]]; then
EOH

$completion_function .= <<'EOH' ;
		COMPREPLY=( $( compgen -W '\
EOH

$completion_list = de_getop_ify_list($completion_list) ;

for my $option (@{$completion_list})
	{
	if($single_and_double_dash)
		{
		$completion_function .= "\t\t\t-$option --$option \\\n" ;
		}
	else
		{
		if(1 == length($option))
			{
			$completion_function .= "\t\t\t-$option \\\n" ;
			}
		else
			{
			$completion_function .= "\t\t\t--$option \\\n" ;
			}
		}
	}
	
$completion_function .= <<"EOF" ;	
			' -- \$cur ) )
	fi

	return 0
}

complete -F $completion_function_name $complete_options $command
EOF

return $completion_function ;
}

#-------------------------------------------------------------------------------

sub de_getop_ify_list
{

=head2 de_getop_ify_list(\@completion_list)

Split L<Getopt::Long> option definitions and remove type information

I<Arguments>

=over 2 

=item * \@completion_list - list of options to create completion for

the options can be simple strings or a L<Getopt::Long> specifications 

=back

I<Returns> - an array reference

I<Exceptions> - carps if $completion_list is not defined

=cut

my ($completion_list) = @_ ;

croak unless defined $completion_list ;

my @de_getopt_ified_list ;

for my $switch (@{$completion_list})
	{
	my @switches = split(/\|/sxm, $switch) ;
	
	#~ print "$switch => \n" ;
	for (@switches) 
		{
		s/=.*$//sxm ;
		s/:.*$//sxm ;
		
		push @de_getopt_ified_list, $_ ;
		}
	}
	
return \@de_getopt_ified_list ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 BUGS AND LIMITATIONS

None so far.

=head1 AUTHOR

	Nadim ibn hamouda el Khemir
	CPAN ID: NH
	mailto: nadim@cpan.org

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::Bash::Completion::Generator

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Term-Bash-Completion-Generator>

=item * RT: CPAN's request tracker

Please report any bugs or feature requests to  L <bug-term-bash-completion-generator@rt.cpan.org>.

We will be notified, and then you'll automatically be notified of progress on
your bug as we make changes.

=item * Search CPAN

L<http://search.cpan.org/dist/Term-Bash-Completion-Generator>

=back

=head1 SEE ALSO

L<Getopt::Long>

L<Tree::Trie>

L<http://wiki.debian.org/Teams/BashCompletion>, the bash completion team. They maintain a lot of
common commands completion scripts.

=cut
