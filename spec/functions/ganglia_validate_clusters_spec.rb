require 'spec_helper'

describe 'ganglia_validate_clusters', :type => :puppet_function do
  it 'should fail with no params' do
    should run.with_params().
      and_raise_error(Puppet::ParseError, /wrong number of arguments/)
  end

  it 'should fail with > 1 param' do
    should run.with_params('a', 'b').
      and_raise_error(Puppet::ParseError, /wrong number of arguments/)
  end

  [ true, false, {}, "foo", nil ].each do |input|
    it 'should fail when not called with an array' do
      should run.with_params(input).
        and_raise_error(Puppet::ParseError, /is not an Array/)
    end
  end

  it 'should fail when passed an empty array' do
    should run.with_params([]).
      and_raise_error(Puppet::ParseError, /Array may not be empty/)
  end

  it 'should fail when passed an array of anything but hashes' do
    clusters = ['foo', 'bar']
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /is not a Hash/)
  end

  it 'should fail when passed an array of empty hashes' do
    clusters = [{}, {}]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /Hash may not be empty/)
  end

  it 'should fail when name key is missing ' do
    clusters = [{ 'address' => 'localhost' }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /must contain a name key/)
  end

  it 'should fail when name key is not a string' do
    clusters = [{ 'name' => ['my cluster'], 'address' => 'localhost' }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /name key must be a String/)
  end

  it 'should fail when address key is missing' do
    clusters = [{ 'name' => 'my cluster' }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /must contain an address key/)
  end

  it 'should fail when address key is not a string|array' do
    clusters = [{ 'name' => 'my cluster', 'address' => {'a' => 1} }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /address key must be a String or Array/)
  end

  it 'work with optional polling_interval key' do
    clusters = [{ 'name' => 'my cluster', 'address' => 'localhost', 'polling_interval' => '10' }]
    should run.with_params(clusters).and_return(clusters)
  end

  it 'work with optional polling_interval key' do
    clusters = [{ 'name' => 'my cluster', 'address' => 'localhost', 'polling_interval' => 10 }]
    should run.with_params(clusters).and_return(clusters)
  end

  it 'should fail when polling_interval key is not a String' do
    clusters = [{ 'name' => 'my cluster', 'address' => 'localhost', 'polling_interval' => [ 10 ] }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /polling_interval key must be a String or Integer/)
  end

  it 'should fail with unknown keys' do
    clusters = [{ 'name' => 'my cluster', 'address' => 'localhost', 'polling_interval' => 10, 'foo' => 1, 'bar' => 2 }]
    should run.with_params(clusters).
      and_raise_error(Puppet::ParseError, /contains unknown keys \(bar foo\)/)
  end

  it 'work with reasonable input - simple example' do
    clusters = [{ 'name' => 'my cluster', 'address' => 'localhost' }]
    should run.with_params(clusters).and_return(clusters)
  end

  it 'work with reasonable input - complex example' do
    clusters = [
      {
        'name'    => 'foo',
        'address' => [
          'foo1.example.org',
          'foo2.example.org',
          'foo3.example.org',
        ],
      },
      {
        'name'             => 'bar',
        'address'          => [
          'bar1.example.org',
          'bar2.example.org',
          'bar3.example.org'
        ],
        'polling_interval' => 42,
      },
      {
        'name'    => 'baz',
        'address' => [
          'baz1.example.org',
          'baz2.example.org',
          'baz3.example.org',
        ],
      },
    ]
    should run.with_params(clusters).and_return(clusters)
  end
end
