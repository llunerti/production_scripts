import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from GeneratorInterface.EvtGenInterface.EvtGenSetting_cff import *

_generator = cms.EDFilter("Pythia8GeneratorFilter",
                         pythiaPylistVerbosity = cms.untracked.int32(0),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         comEnergy = cms.double(13000.0),
                         maxEventsToPrint = cms.untracked.int32(0),
                         ExternalDecays = cms.PSet(
                             EvtGen130 = cms.untracked.PSet(
                                 convertPythiaCodes = cms.untracked.bool(False),
                                 decay_table = cms.string('GeneratorInterface/EvtGenInterface/data/DECAY_2014_NOLONGLIFE.DEC'),
                                 list_forced_decays = cms.vstring('MyD_s+', 'MyD_s-'),
                                 operates_on_particles = cms.vint32(),
                                 particle_property_file = cms.FileInPath('evt_2014_M1p5_V5e-03.pdl'),
                                 user_decay_embedded = cms.vstring(
                                     'Alias      MyD_s+      D_s+',
                                     'Alias      MyD_s-      D_s-',
                                     'ChargeConj MyD_s+ MyD_s-',
                                     'Decay MyD_s+', # Ds->hnl mu
                                     '  1.000 N_1 mu+ PHSP;',
                                     'Enddecay',
                                     'CDecay MyD_s-',
                                     'Decay N_1', #hnl-> pi mu
                                     '  0.5   pi- mu+ PHSP;',
                                     '  0.5   pi+ mu- PHSP;',
                                     'Enddecay',
                                     'End'
                                 )
                             ),
                             parameterSets = cms.vstring('EvtGen130')
                         ),

                         PythiaParameters = cms.PSet(
                           pythia8CommonSettingsBlock,
                           pythia8CP5SettingsBlock,
                           processParameters = cms.vstring(
                               "SoftQCD:nonDiffractive = on",
                               'PTFilter:filter = on', # this turn on the filter
                               'PTFilter:quarkToFilter = 4', # PDG id of q quark
                               'PTFilter:scaleToFilter = 1.0'), #best 1.0
                           parameterSets = cms.vstring('pythia8CommonSettings',
                                                       'pythia8CP5Settings',
                                                       'processParameters'
                           )
                         ),

)

from GeneratorInterface.Core.ExternalGeneratorFilter import ExternalGeneratorFilter
generator = ExternalGeneratorFilter(_generator, _external_process_waitTime_=cms.untracked.uint32(300)) 

generator.PythiaParameters.processParameters.extend(EvtGenExtraParticles)

trigMuFilter = cms.EDFilter(
    "PythiaFilter",
    ParticleID = cms.untracked.int32(13),
    MinPt           = cms.untracked.double(6.),
    MinEta          = cms.untracked.double(-1.6),
    MaxEta          = cms.untracked.double(1.6)
)

ProductionFilterSequence = cms.Sequence(generator*trigMuFilter)
