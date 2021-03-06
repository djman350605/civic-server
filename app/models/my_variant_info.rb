class MyVariantInfo
  attr_reader :variant

  def initialize(variant_id)
    @variant = Variant.find(variant_id)
  end

  def response
    Rails.cache.fetch(cache_key(variant.id), expires_in: 24.hours) do
      if hgvs = HgvsExpression.my_gene_info_hgvs(variant)
        make_request(hgvs)
      else
        {}
      end
    end
  end

  def primary_fields
    [
      'clinvar.variant_id',
      'clinvar.rcv.clinical_significance',
      'cosmic.cosmic_id',
      'dbsnp.rsid',
      'emv.egl_classification',
      'exac_nontcga.adj_af',
      'snpeff.ann.effect',
      'snpeff.ann.putative_impact'
    ]
  end

  def secondary_fields
    [
      'cadd.consdetail',
      'cadd.consequence',
      'cadd.sift.cat',
      'cadd.sift.val',
      'cadd.polyphen.cat',
      'cadd.polyphen.val',
      'clinvar.HGVS.coding',
      'clinvar.HGVS.genomic',
      'clinvar.HGVS.non-coding',
      'clinvar.HGVS.protein',
      'clinvar.omim',
      'dbnsfp.interpro_domain',
      'emv.egl_protein',
      'emv.egl_variant',
      'emv.hgvs'
    ]
  end

  private
  def make_request(hgvs)
    Scrapers::Util.make_get_request(my_variant_info_url(hgvs))
  end

  def my_variant_info_url(coordinate_string)
    all_fields = (primary_fields + secondary_fields).join(',')
    URI.encode("http://myvariant.info/v1/variant/#{coordinate_string}?fields=#{all_fields}")
  end

  def cache_key(variant_id)
    "myvariant_info_#{variant_id}"
  end
end
