require 'yaml'

describe 'README' do
  let(:readme) do
    readme = YAML.load_file(File.expand_path('./readme_definitions.yml', File.dirname(__FILE__)))
  end

  it 'has a hook' do
    expect(readme['has_hook']).to eq true
  end

  it 'links to badges' do
    expect(readme['links_to_badges']).to eq true
  end

  it 'has a simple example' do
    expect(readme['has_simple_example']).to eq true
  end

  it 'shows that eldr apps are rack apps' do
    expect(readme['are_rack_apps']).to eq true
  end

  it 'has installation instructions' do
    expect(readme['installation_instructions']).to eq true
  end

  it 'has a features list' do
    expect(readme['features_list']).to eq true
  end

  it 'has a quickstart section' do
    expect(readme['has_quickstart']).to eq true
  end

  describe 'quickstart' do
    it 'has a run down that goes from install, file, to booting' do
      expect(readme['quickstart']['has_rundown']).to eq true
    end

    it 'shows how to render a template' do
      expect(readme['quickstart']['templates']).to eq true
    end

    it 'shows how to do helpers' do
      expect(readme['quickstart']['helpers']).to eq true
    end

    it 'shows how to do rails styling routing' do
      expect(readme['quickstart']['rails_style_routing']).to eq true
    end

    it 'shows how to do rails style responses' do
      expect(readme['quickstart']['rails_style_responses']).to eq true
    end

    it 'shows how to rails style requests' do
      expect(readme['quickstart']['rails_style_requests']).to eq true
    end

    it 'shows how to do extensions' do
      expect(readme['quickstart']['extensions']).to eq true
    end

    it 'shows how to use builder inside an app class' do
      expect(readme['quickstart']['builder']).to eq true
    end

    it 'goes over redirects' do
      expect(readme['quickstart']['redirects']).to eq true
    end

    describe 'handlers' do
      it 'goes over handlers as just things that take a call' do
        expect(readme['quickstart']['handlers']['call']).to eq true
      end

      it 'shows how we can use any object' do
        expect(readme['quickstart']['handlers']['any_object']).to eq true
      end

      describe 'Action Objects' do
        it 'shows how we can use action objects' do
          expect(readme['quickstart']['handlers']['action_objects']).to eq true
        end

        it 'shows how we can use action objects in a controller' do
          expect(readme['quickstart']['handlers']['action_objects_example']).to eq true
        end
      end
    end

    it 'has a section on testing' do
      expect(readme['quickstart']['testing']).to eq true
    end
  end

  it 'loop back around and show Eldr apps are just rack apps' do
    expect(readme['has_rack_loop']).to eq true
  end

  it 'mention examples folder' do
    expect(readme['mentions_examples_folder']).to eq true
  end

  it 'link to places to get help' do
    expect(readme['has_help']).to eq true
  end

  it 'has a section on contributing' do
    expect(readme['has_contributing']).to eq true
  end

  it 'has a license' do
    expect(readme['has_license']).to eq true
  end
end
