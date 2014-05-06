=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::Component::Tools::Blast::HspQueryPlot;

use strict;
use warnings;

use EnsEMBL::Draw::DrawableContainer;
use EnsEMBL::Web::Document::Image;
use EnsEMBL::Web::Container::HSPContainer;

use parent qw(EnsEMBL::Web::Component::Tools::Blast);

sub content {
  my $self          = shift;
  my $hub           = $self->hub;
  my $object        = $self->object;
  my $job           = $object->get_requested_job({'with_all_results' => 1});
  my $results       = $job && $job->status eq 'done' ? $job->result : [];
  my @pointer_cols  = $hub->colourmap->build_linear_gradient(@{$self->blast_pointer_style->{'gradient'}});
  my $html          = '';

  if (@$results) {

    # Draw the HSP image
    my $image                   = EnsEMBL::Web::Document::Image->new($hub);
    $image->drawable_container  = EnsEMBL::Draw::DrawableContainer->new(EnsEMBL::Web::Container::HSPContainer->new($object, $job, \@pointer_cols), $hub->get_imageconfig('hsp_query_plot'));
    $image->imagemap            = 'yes';
    $image->set_button('drag');

    # Add colour key info table
    my $steps         = 5; # we need to display 1 + 5 labels (0, 20 .. 100)
    my %labels        = map { int($_ * (@pointer_cols - 1) / $steps) => int($_ * 100 / $steps) } 0 .. $steps;
    my $swatch        = join '', map { sprintf '<div style="background:#%s">%s</div>', $pointer_cols[$_], $labels{$_} // '' } 0 .. $#pointer_cols;
    my $legend        = sprintf '<div class="swatch-legend">Lower %%ID  &#9668;<span>%s</span>&#9658; Higher %%ID </div>', ' ' x 33;

    my $swatch_table  = $self->new_table(
      [
        {'key' => 'ftype',  'title' => 'Feature type'},
        {'key' => 'colour', 'title' => 'Colour'},
      ], [{
        'ftype'  => {'value' => ($job->job_data->{'search_type'} || '') =~ /BLAST/ ?  'BLAST hit' : 'BLAT hit'},
        'colour' => {'value' => qq(<div class="swatch-wrapper"><div class="swatch">$swatch</div>$legend</div>)},
      }], {}
    );

    # final HTML
    $html .= sprintf('
      <h3><a rel="_blast_queryplot" class="toggle set_cookie open" href="#">HSP distribution on query sequence:</a></h3>
      <div class="_blast_queryplot toggleable">%s</div>
      <h3><a rel="_blast_key_table" class="toggle set_cookie open" href="#">Key</a></h3>
      <div class="_blast_key_table toggleable">%s</div>',
      $image->render,
      $swatch_table->render
    );
  }

  return $html;
}

1;
