/*
 * Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

Ensembl.Panel.LocalContext = Ensembl.Panel.LocalContext.extend({

  init: function() {
    this.base.apply(this, arguments);

    Ensembl.EventManager.register('enableBlastButton',  this, this.enableBlastButton);
    Ensembl.EventManager.register('runBlastSeq',        this, this.runBlastSeq);
  },

  enableBlastButton: function(seq) {
    var panel = this;

    this.elLk.blastForm = this.el.find('.tool_buttons').find('a._blast_button').on('click', function (e) {
      e.preventDefault();
      panel.runBlastSeq(seq);
    }).end().find('form._blast_form');

    return !!this.elLk.blastForm.length;
  },

  runBlastSeq: function(seq) {
    if (this.elLk.blastForm) {
      this.elLk.blastForm.find('input[name=query_sequence]').val(seq);
      this.elLk.blastForm.submit();
    }
  }
});
