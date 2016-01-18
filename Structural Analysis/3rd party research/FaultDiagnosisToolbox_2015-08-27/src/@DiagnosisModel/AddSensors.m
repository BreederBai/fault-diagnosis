function ms = AddSensors( model, s, varargin )
% Add sensor equations to a model
%
%  model2 = model.AddSensor( s, options )
%
%  s          Description of sensors to add
%             s can be a cell-array (or just a string) of strings
%             with the names of sensors to add or indices
%             into the known variables (model.x) which sensors to add.
%             It is only possible to add sensors measuring single
%             variables in x. If functions of variables in x are
%             measured, extend the model with a new variable first.
%             
%             If the corresponding variable can be faulty, see
%             SensorLocationsWithFaults, a fault will be added
%             automatically.
%
%  Options can be given as a number of key/value pairs
%
%  Key        Value
%    name       Cell array with names of new sensor variables
%
%             Important: If no output argument is given, the current
%             object will be modified, i.e., it is allowed to write
%                model.AddSensor( s );
%             To create a new object, with the new sensor, without
%             modifying the original model, instead write
%                model2 = model.AddSensor( s );

% Copyright Erik Frisk, Mattias Krysander, 2015
% Distributed under the MIT License.
% (See accompanying file LICENSE or copy at
%  http://opensource.org/licenses/MIT)

  pa = inputParser;
  pa.addOptional( 'name', {} );
  pa.parse(varargin{:});
  opts = pa.Results;

  
  if ~isempty(opts.name) && length(opts.name)~=length(s)
    error('If sensor names are provided, all sensors must be named');
  end
  
  if isa(s,'char')
    [~,sPos] = ismember(s, model.x);
  elseif isa(s, 'cell')
    [~,sPos] = ismember(s, model.x);
  elseif isa(s,'double') && min(s)>0 && max(s) <= numel(model.x)
    sPos = s;
  else
    sPos = 0;
  end
  if any(sPos > 0)
    if nargout==0
      ms = model;
    else 
      ms = model.copy();
    end
    
    nx = size(ms.X,2);
    nf = size(ms.F,2);
    nz = size(ms.Z,2);
    ne = size(ms.X,1);

    for ii=1:numel(sPos)
      if sPos(ii)>0
        if ismember(sPos(ii),model.Pfault)
          sensorFault = true;
        else
          sensorFault = false;
        end
        if isempty(opts.name)
          if sum(sPos(1:ii-1)==sPos(ii))>0
            m = sum(sPos(1:ii-1)==sPos(ii));
            name = sprintf('z%d%s', m+1, ms.x{sPos(ii)});
          else
            name = sprintf('z%s', ms.x{sPos(ii)});
          end
        else
          name = opts.name{ii};
        end
        ms.X(end+1,:) = zeros(1,nx); 
        ms.X(end,sPos(ii)) = 1;
        ms.Z(end+1,:) = zeros(1,nz); 
        ne = ne + 1;

        ms.F(end+1,:) = zeros(1,nf);
        if sensorFault
          fName = sprintf('f%s', name);
          ms.f{end+1} = fName;
          nf = nf + 1;
          ms.F(:,end+1) = zeros(ne,1);
          ms.F(ne,nf) = 1;
          ms.syme{end+1} = sym(name)==sym(ms.x{sPos(ii)}) + sym(fName);
        else
          ms.syme{end+1} = sym(name)==sym(ms.x{sPos(ii)});
        end
                
        ms.Z = [ms.Z zeros(ne,1)];
        ms.Z(ne,nz+1) = 1;
        ms.z{end+1} = name;

        ms.e{end+1} = ms.idGen.NewE();        
        nz = nz + 1;
      end
    end
  else
    warning('Incorrect sensor position');
  end
end
